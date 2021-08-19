// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.5;

import "./ERC20.sol";
import "./IERC20.sol";
import "./Ownable.sol";

contract CTF is ERC20, Ownable {
    address public farmingContract;
    using SafeMath for uint256;

    uint256 private initialMint = 26000000 * 10**18; //26m tokens minted when deployed

    uint256 private numTokensToMigrateV1 = 59576 * 10**18; //1,4m tokens to be migrated from v1
    uint256 private numTokensToMigrateV2 = 59000000 * 10**18; //59m tokens to be migrated from v2

    uint256 private migratedV1;
    uint256 private migratedV2;

    //uint256 private deployedAt;

    IERC20 public oldCTFV1 = IERC20(0xB29f522EF86e212bcEe1ff539Ad61E90aCA8743f);
    IERC20 public oldCTFV2 = IERC20(0x695c27f34f994565198a74bd6F402707a6bB51AD);

    event ChangedFarmingContract(address indexed farmingContractAddress, address indexed _owner);

    constructor() ERC20("CTF Token", "CTF") {
        _mint(_msgSender(), initialMint);
      //  deployedAt = block.timestamp;
    }

    function mint(address _to, uint256 _amt) public {
        require(farmingContract == msg.sender, "You are not authorised to mint");
        require(totalSupply().add(_amt) <= 86400000 * (10**18) , "Unable to mint more"); // total supply = 86.4m
        _mint(_to, _amt);
    }

    function changeFarmingContract(address _farmingContractAddress) public onlyOwner {
        require(farmingContract == address(0), "Farming Contract Already Added");
        farmingContract = _farmingContractAddress;
        emit ChangedFarmingContract(_farmingContractAddress, _msgSender());
    }

    // migrate from v1 to v3
    function migrateV1() public {
        uint256 oldBalanceV1 = oldCTFV1.balanceOf(_msgSender());
        require(oldBalanceV1 > 0 , "Not eligible to migrate from V1");

        require(migratedV1.add(oldBalanceV1) <= numTokensToMigrateV1, "V1: Cant migrate more than allocated");
        oldCTFV1.transferFrom(_msgSender(), 0x000000000000000000000000000000000000dEaD, oldBalanceV1);
        
        _mint(_msgSender(), oldBalanceV1);
        migratedV1 = migratedV1.add(oldBalanceV1);
    }

    // migrate from v2 to v3
    function migrateV2() public {
        uint256 oldBalanceV2 = oldCTFV2.balanceOf(_msgSender());
        require(oldBalanceV2 > 0 , "Not eligible to migrate from V2");

        require(migratedV2.add(oldBalanceV2) <= numTokensToMigrateV2, "V2: Cant migrate more than allocated");
        oldCTFV2.transferFrom(_msgSender(), 0x000000000000000000000000000000000000dEaD, oldBalanceV2);
        
        _mint(_msgSender(), oldBalanceV2);
        migratedV2 = migratedV2.add(oldBalanceV2);
    }

    // in case of wrong address by mistake
    function changeV1Address(address _address) public onlyOwner {
        require(oldCTFV1 != IERC20(_address), "Address is the same");
        oldCTFV1 = IERC20(_address);
    }

    function changeV2Address(address _address) public onlyOwner {
        require(oldCTFV2 != IERC20(_address), "Address is the same");
        oldCTFV2 = IERC20(_address);
    }

}
