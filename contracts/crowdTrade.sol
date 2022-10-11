pragma solidity 0.8.7;

//Supports only native token right now

contract PoolInvestment{
    
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

    //Vote to buy the token
    function vote(uint256 poolId) external{
        require(stakerPoolBalance[msg.sender][poolId] > 0, "You are not eligible to vote");
        //To be implemented 
    }

}
