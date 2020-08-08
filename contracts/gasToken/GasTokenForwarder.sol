pragma solidity ^0.5.13;
import "./ICHITOKEN.sol";
import "../RelayerManager.sol";
import "../libs/SafeMath.sol";
import "../libs/Ownable.sol";
import "./GasTokenImplementationLogic.sol";

contract GasTokenForwarder is Ownable {
    using SafeMath for uint256;

    ICHITOKEN public chiToken;
    RelayerManager public relayerManager;
    GasTokenImplementationLogic public gasTokenImplLogic;

    // MODIFIERS
    modifier onlyRelayerOrOwner() {
        require(
            relayerManager.getRelayerStatus(msg.sender) || msg.sender == owner(),
            "You are not allowed to perform this operation"
        );
        _;
    }

    constructor(
        address owner,
        address _chiTokenAddress,
        address _relayerManagerAddress,
        address _gasTokenImplAddress
    ) public Ownable(owner) {
        require(_chiTokenAddress != address(0), "ChiToken Contract Address cannot be 0");
        require(_relayerManagerAddress != address(0), "RelayerManager Contract Address cannot be 0");
        require(_gasTokenImplAddress != address(0), "GasTokenImpl Contract Address address cannot be 0");

        chiToken = ICHITOKEN(_chiTokenAddress);
        relayerManager = RelayerManager(_relayerManagerAddress);
        gasTokenImplLogic = GasTokenImplementationLogic(_gasTokenImplAddress);
    }

    function addRelayerManager(address _relayerManagerAddress) public onlyRelayerOrOwner {
        require(
            _relayerManagerAddress != address(0),
            "Manager address can not be 0"
        );
        relayerManager = RelayerManager(_relayerManagerAddress);
    }

    function addGasTokenImpl(address _gasTokenImplLogicAddress) public onlyRelayerOrOwner {
        require(
            _gasTokenImplLogicAddress != address(0),
            "GasTokenImpl contract address can not be 0"
        );
        gasTokenImplLogic = GasTokenImplementationLogic(_gasTokenImplLogicAddress);
    }

    function balanceOfGasToken(address who) external view returns (uint256) {
        return chiToken.balanceOf(who);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return chiToken.allowance(owner, spender);
    }

    function() external payable onlyRelayerOrOwner{
        address target = address(gasTokenImplLogic);
        assembly {
            // let _target := sload()
            calldatacopy(0x0, 0x0, calldatasize)
            let result := delegatecall(gas, target, 0x0, calldatasize, 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize)
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize)}
        }
    }
}