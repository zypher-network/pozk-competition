// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IVerifier.sol";

import "./risc0/ControlID.sol";
import "./risc0/RiscZeroGroth16Verifier.sol";

contract ZKVMVerifier is ERC165, IVerifier, RiscZeroGroth16Verifier, Ownable {
    bytes32 public constant IMAGE = hex"bb92829fe24b9994bb93a6a87c2e63fd92f02120cbb1a82a06398503ba9a2041";

    /// admin list for register account
    mapping(address => bool) public allowlist;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IVerifier).interfaceId || super.supportsInterface(interfaceId);
    }

    function name() external pure returns (string memory) {
        return "Competition-3";
    }

    function permission(address sender) external view returns (bool) {
        return allowlist[sender];
    }

    /// show how to serialize/deseriaze the inputs params
    /// e.g. "uint256,bytes32,string,bytes32[],address[],ipfs"
    function inputs() external pure returns (string memory) {
        return "bytes32";
    }

    /// show how to serialize/deserialize the publics params
    /// e.g. "uint256,bytes32,string,bytes32[],address[],ipfs"
    function publics() external pure returns (string memory) {
        return "uint256[5]";
    }

    function allow(address account, bool _allow) external onlyOwner {
        allowlist[account] = _allow;
    }

    constructor() RiscZeroGroth16Verifier(ControlID.CONTROL_ROOT, ControlID.BN254_CONTROL_ID) Ownable (msg.sender) {}

    function verify(bytes calldata _publics, bytes calldata _proof) external view returns (bool) {
        bytes32 publics = abi.decode(_publics, (bytes32));

        this.verifyRisc0(_proof, IMAGE, publics);

        return true;
    }
}
