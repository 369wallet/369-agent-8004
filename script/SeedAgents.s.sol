// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {IAgentIdentityRegistry} from "../src/interfaces/IAgentIdentityRegistry.sol";

/// @title SeedAgents
/// @notice Registers the 369 Agent Store seed agents (Sentinel, Yield Scout,
///         Dust Sweeper, Tax Ledger) against the deployed identity registry
///         in a FIXED order so the assigned ids are deterministic
///         (#2..#5 when nextId() == 2). Prints each assigned id.
///
/// Usage:
///   IDENTITY_REGISTRY=0xAceB520444ddeDec663277FC866ab77E8085918e \
///   METADATA_URIS="<sentinel_url>,<yield_url>,<dust_url>,<tax_url>" \
///   forge script script/SeedAgents.s.sol:SeedAgents \
///       --rpc-url arc_testnet_public \
///       --broadcast
contract SeedAgents is Script {
    function run() external {
        address registry = vm.envAddress("IDENTITY_REGISTRY");
        string[] memory uris = vm.envString("METADATA_URIS", ",");
        uint256 pk = _signerKey();

        console2.log("Seeding", uris.length, "agents to registry:");
        console2.logAddress(registry);

        vm.startBroadcast(pk);
        for (uint256 i = 0; i < uris.length; i++) {
            uint256 agentId = IAgentIdentityRegistry(registry).registerAgent(uris[i]);
            console2.log("  registered agentId:", agentId);
            console2.log("    metadataURI:", uris[i]);
        }
        vm.stopBroadcast();
    }

    /// @dev Accepts PRIVATE_KEY with or without the 0x prefix.
    function _signerKey() internal view returns (uint256) {
        try vm.envUint("PRIVATE_KEY") returns (uint256 v) {
            return v;
        } catch {
            string memory raw = vm.envString("PRIVATE_KEY");
            return vm.parseUint(string.concat("0x", raw));
        }
    }
}
