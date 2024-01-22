// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./hts-precompile/HederaTokenService.sol";
import "./hts-precompile/ExpiryHelper.sol";
import "./hts-precompile/KeyHelper.sol";

contract FairmintTokenContract is HederaTokenService, ExpiryHelper, KeyHelper {
    string name = "tokenName";
    string symbol = "tokenSymbol";
    string memo = "memo";
    int64 initialTotalSupply = 1000;
    int64 maxSupply = 0;
    int32 decimals = 8;
    bool freezeDefaultStatus = false;

    struct FairmintConfiguration {
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 amountPerMint;
    }
    mapping(address => FairmintConfiguration) fairmintConfiguration;

    event ResponseCode(int responseCode);
    event CreatedToken(address tokenAddress);
    event MintedToken(int64 newTotalSupply, int64[] serialNumbers);
    event KycGranted(bool kycGranted);

    constructor() {}

    function createFairmintTokenPublic(FairmintConfiguration memory config) public payable {
        IHederaTokenService.TokenKey[]
            memory keys = new IHederaTokenService.TokenKey[](5);
        keys[0] = getSingleKey(
            KeyType.ADMIN,
            KeyType.PAUSE,
            KeyValueType.INHERIT_ACCOUNT_KEY,
            bytes("")
        );
        keys[1] = getSingleKey(
            KeyType.KYC,
            KeyValueType.INHERIT_ACCOUNT_KEY,
            bytes("")
        );
        keys[2] = getSingleKey(
            KeyType.FREEZE,
            KeyValueType.INHERIT_ACCOUNT_KEY,
            bytes("")
        );
        keys[3] = getSingleKey(
            KeyType.WIPE,
            KeyValueType.INHERIT_ACCOUNT_KEY,
            bytes("")
        );
        keys[4] = getSingleKey(
            KeyType.SUPPLY,
            KeyValueType.INHERIT_ACCOUNT_KEY,
            bytes("")
        );

        IHederaTokenService.Expiry memory expiry = IHederaTokenService.Expiry(
            0,
            address(this),
            8000000
        );

        IHederaTokenService.HederaToken memory token = IHederaTokenService
            .HederaToken(
                name,
                symbol,
                address(this),
                memo,
                false,
                maxSupply,
                freezeDefaultStatus,
                keys,
                expiry
            );

        (int responseCode, address tokenAddress) = HederaTokenService
            .createFungibleToken(token, initialTotalSupply, decimals);

        if (responseCode != HederaResponseCodes.SUCCESS) {
            revert();
        }

        fairmintConfiguration[tokenAddress] = config;

        emit CreatedToken(tokenAddress);
    }

    function fairmintPublic(
        address token,
        int64 amount
    )
        public
        returns (
            int responseCode,
            int64 newTotalSupply,
            int64[] memory serialNumbers
        )
    {
        require(uint256(uint64(amount)) <= fairmintConfiguration[token].amountPerMint, "Minting amount exceeded");
        require((block.timestamp >= fairmintConfiguration[token].startTimestamp), "Minting did not start");
        require((block.timestamp <= fairmintConfiguration[token].endTimestamp), "Minting is over");

        (responseCode, newTotalSupply, serialNumbers) = HederaTokenService
            .mintToken(token, amount, new bytes[](0));
        emit ResponseCode(responseCode);

        if (responseCode != HederaResponseCodes.SUCCESS) {
            revert();
        }

        emit MintedToken(newTotalSupply, serialNumbers);

        responseCode = HederaTokenService.transferToken(token, address(this), msg.sender, amount);
        emit ResponseCode(responseCode);

        if (responseCode != HederaResponseCodes.SUCCESS) {
            revert();
        }
    }
}
