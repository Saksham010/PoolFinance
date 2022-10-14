pragma solidity 0.8.7;

//Supports only native token right now
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Router {

  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);


  function swapExactETHForTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable returns (uint[] memory amounts);
}


contract PoolInvestment{

    //Uniswap router
    address private constant UNISWAP_V2_ROUTER =0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //Intermediate token
    address private constant ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //ETH address (In Token);


    //Total StakeBasis
    mapping(uint256=>uint256) totalBasisVoted; //PoolId->TotalStakeVoted

    //Pool Counter
    uint256 poolID = 0;

    struct Pool{
        address tokenAddress;
        address poolCreator;
        uint256 poolMaxLimit; // In wei denomination
        uint256 poolDuration;
        bool poolUnlimited;
        uint256 poolBalance; //In wei denomination
        uint256 poolParticipants; //Number of participants
    }

    //Pool ID => Pool struct
    mapping (uint256 => Pool) poolData;  
    //Staker => PoolID => amount
    mapping(address=>mapping(uint256=>uint256)) stakerPoolBalance;

    //Create a new pool for a token address
    function createPool(address tokenAddress,uint256 poolMaxLimit, uint256 poolDuration, bool poolUnlimited) external{
        //Incrementing poolID
        poolID++;

        //Registering pool data
        poolData[poolID] = Pool(tokenAddress, msg.sender,poolMaxLimit,poolDuration,poolUnlimited,0,0);
    }

    //Deposit native token
    function depositToPool(uint256 poolId)payable external{
        uint256 poolBALANCE = poolData[poolId].poolBalance;
        uint256 poolLIMIT = poolData[poolId].poolMaxLimit;

        //Pool overflow check if there is a limit
        if(poolData[poolId].poolUnlimited == false){

            require(poolBALANCE + msg.value < poolLIMIT,"The deposit exceeds pool limit");
        }

        //Check if the pool participant is unique
        if(stakerPoolBalance[msg.sender][poolId] == 0){
            //Incrementing pool participants if the user is unique
            poolData[poolId].poolParticipants += 1;
        }

        //Registering staked token
        stakerPoolBalance[msg.sender][poolId] = msg.value;  //Msgvalue is in wei denomination

        //Incrementing pool balance
        poolData[poolId].poolBalance += msg.value;
        

    } 

    //Calculates percentage
    function percent(uint numerator, uint denominator, uint precision) public returns(uint256) {

         // caution, check safe-to-multiply here
        uint _numerator  = numerator * 10 ** (precision+1);
        // with rounding of last digit
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return ( _quotient);
  }

    //Swap to buy token
    function swap(address _tokenOut, uint256 _amountIn, uint256 _amountOutMin) internal{

        //Restricting Eth as a fuding token
        address _tokenIn = ETH;
        address _to = address(this);

        //Approving uniswap router to handle token     
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        address[] memory path;
        path = new address[](3);
        path[0] = _tokenIn;
        path[1] = WETH;
        path[2] = _tokenOut;

        //Calling uniswap router to swap token
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp + 15
        );
    }


    //Vote to buy the token
    function vote(uint256 poolId) external{
        uint256 depositedAmount = stakerPoolBalance[msg.sender][poolId];
        require(depositedAmount > 0, "You are not eligible to vote");
        //To be implemented 

        //Total balance of the pool
        uint256 _poolBalance = poolData[poolId].poolBalance;

        //Stake ratio
        uint256 stakeBasis = percent(depositedAmount, _poolBalance, 3);

        //Updating the vote according to stake
        totalBasisVoted[poolId] += stakeBasis;

        //If the vote exceeds 50% buy the token
        if(totalBasisVoted[poolId] >= 500){
            //Buy 
            address _tokenOut = poolData[poolId].tokenAddress;
            uint256 _amountIn = poolData[poolId].poolBalance; // wei denomination
            uint256 _amountOutMin = 0;
            swap(_tokenOut,_amountIn,_amountOutMin); //Buying the given token

            //Returning token to the rightful stakers

            //To be implemented
        }
    }

}
