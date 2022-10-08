pragma solidity 0.8.7;

contract PoolInvestment{

    struct TokenDetail{
        address tokenAddress;

    }

    //Funder address -> Detail of token
    mapping (address=>TokenDetail) funders;

}
