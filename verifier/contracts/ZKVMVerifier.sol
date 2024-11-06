// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IVerifier.sol";

import "./risc0/ControlID.sol";
import "./risc0/RiscZeroGroth16Verifier.sol";

contract ZKVMVerifier is ERC165, IVerifier, RiscZeroGroth16Verifier {
    bytes32 public constant IMAGE = hex"bb92829fe24b9994bb93a6a87c2e63fd92f02120cbb1a82a06398503ba9a2041";

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IVerifier).interfaceId || super.supportsInterface(interfaceId);
    }

    function name() external pure returns (string memory) {
        return "Competition-3";
    }

    function permission() external pure returns (bool) {
        return true;
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

    constructor() RiscZeroGroth16Verifier(ControlID.CONTROL_ROOT, ControlID.BN254_CONTROL_ID) {}

    function verify(bytes calldata _publics, bytes calldata _proof) external view returns (bool) {
        bytes32 publics = abi.decode(_publics, (bytes32));

        this.verifyRisc0(_proof, IMAGE, publics);

        return true;
    }
}
