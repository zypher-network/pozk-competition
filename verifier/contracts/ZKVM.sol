// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./ITask.sol";

contract ZKVM is Initializable, OwnableUpgradeable {
    address public task;
    address public verifier;

    /// admin list for register account
    mapping(address => bool) public allowlist;

    function initialize(address _task, address _verifier) public initializer {
        __Ownable_init(msg.sender);
        task = _task;
        verifier = _verifier;
    }

    function setTask(address _task) external onlyOwner {
        task = _task;
    }

    function setVerifier(address _verifier) external onlyOwner {
        verifier = _verifier;
    }

    function allow(address account, bool _allow) external onlyOwner {
        allowlist[account] = _allow;
    }

    function create(bytes calldata inputs, bytes calldata publics) external {
        require(allowlist[msg.sender], "P");
        ITask(task).create(address(this), owner(), 0, inputs, publics);
    }
}
