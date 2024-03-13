// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @dev Settings keys.
 */
library LibConstants {
    /// Object Types

    bytes12 internal constant OBJECT_TYPE_ADDRESS = "ADDRESS";
    bytes12 internal constant OBJECT_TYPE_ENTITY = "ENTITY";
    bytes12 internal constant OBJECT_TYPE_POLICY = "POLICY";
    bytes12 internal constant OBJECT_TYPE_FEE = "FEE";
    bytes12 internal constant OBJECT_TYPE_CLAIM = "CLAIM";
    bytes12 internal constant OBJECT_TYPE_DIVIDEND = "DIVIDEND";
    bytes12 internal constant OBJECT_TYPE_PREMIUM = "PREMIUM";
    bytes12 internal constant OBJECT_TYPE_ROLE = "ROLE";
    bytes12 internal constant OBJECT_TYPE_GROUP = "GROUP";

    /// Reserved IDs

    string internal constant EMPTY_IDENTIFIER = "";
    string internal constant SYSTEM_IDENTIFIER = "System";
    string internal constant NDF_IDENTIFIER = "NDF";
    string internal constant STM_IDENTIFIER = "Staking Mechanism";
    string internal constant SSF_IDENTIFIER = "SSF";
    string internal constant NAYM_TOKEN_IDENTIFIER = "NAYM"; //This is the ID in the system as well as the token ID
    string internal constant DIVIDEND_BANK_IDENTIFIER = "Dividend Bank"; //This will hold all the dividends
    string internal constant NAYMS_LTD_IDENTIFIER = "Nayms Ltd";

    /// Reserved Ids in bytes32

    bytes32 internal constant SYSTEM_IDENTIFIER_BYTES32 =
        0x53797374656d0000000000000000000000000000000000000000000000000000; // LibHelpers._stringToBytes32(LC.SYSTEM_IDENTIFIER));

    /// Roles

    string internal constant ROLE_SYSTEM_ADMIN = "System Admin";
    string internal constant ROLE_SYSTEM_MANAGER = "System Manager";
    string internal constant ROLE_SYSTEM_UNDERWRITER = "System Underwriter";

    string internal constant ROLE_ENTITY_ADMIN = "Entity Admin";
    string internal constant ROLE_ENTITY_MANAGER = "Entity Manager";
    string internal constant ROLE_ENTITY_BROKER = "Broker";
    string internal constant ROLE_ENTITY_INSURED = "Insured";
    string internal constant ROLE_ENTITY_CP = "Capital Provider";
    string internal constant ROLE_ENTITY_CONSULTANT = "Consultant"; // note NEW name for ROLE_SERVICE_PROVIDER
    string internal constant ROLE_ENTITY_TOKEN_HOLDER = "Token Holder";

    string internal constant ROLE_ENTITY_COMPTROLLER_COMBINED = "Comptroller Combined";
    string internal constant ROLE_ENTITY_COMPTROLLER_WITHDRAW = "Comptroller Withdraw";
    string internal constant ROLE_ENTITY_COMPTROLLER_CLAIM = "Comptroller Claim";
    string internal constant ROLE_ENTITY_COMPTROLLER_DIVIDEND = "Comptroller Dividend";

    /// old roles

    string internal constant ROLE_SPONSOR = "Sponsor";
    string internal constant ROLE_CAPITAL_PROVIDER = "Capital Provider";
    string internal constant ROLE_INSURED_PARTY = "Insured";
    string internal constant ROLE_BROKER = "Broker";
    string internal constant ROLE_SERVICE_PROVIDER = "Service Provider";

    string internal constant ROLE_UNDERWRITER = "Underwriter";
    string internal constant ROLE_CLAIMS_ADMIN = "Claims Admin";
    string internal constant ROLE_TRADER = "Trader";
    string internal constant ROLE_SEGREGATED_ACCOUNT = "Segregated Account";
    string internal constant ROLE_ONBOARDING_APPROVER = "Onboarding Approver";

    /// Groups

    string internal constant GROUP_SYSTEM_ADMINS = "System Admins";
    string internal constant GROUP_SYSTEM_MANAGERS = "System Managers";
    string internal constant GROUP_SYSTEM_UNDERWRITERS = "System Underwriters";

    string internal constant GROUP_TENANTS = "Tenants";
    string internal constant GROUP_MANAGERS = "Managers"; // a group of roles that can be assigned by both system and
        // entity managers

    string internal constant GROUP_START_TOKEN_SALE = "Start Token Sale";
    string internal constant GROUP_EXECUTE_LIMIT_OFFER = "Execute Limit Offer";
    string internal constant GROUP_CANCEL_OFFER = "Cancel Offer";
    string internal constant GROUP_INTERNAL_TRANSFER_FROM_ENTITY = "Internal Transfer From Entity";
    string internal constant GROUP_EXTERNAL_WITHDRAW_FROM_ENTITY = "External Withdraw From Entity";
    string internal constant GROUP_EXTERNAL_DEPOSIT = "External Deposit";
    string internal constant GROUP_PAY_SIMPLE_CLAIM = "Pay Simple Claim";
    string internal constant GROUP_PAY_SIMPLE_PREMIUM = "Pay Simple Premium";
    string internal constant GROUP_PAY_DIVIDEND_FROM_ENTITY = "Pay Dividend From Entity";

    string internal constant GROUP_POLICY_HANDLERS = "Policy Handlers"; // note replaced with GROUP_PAY_SIMPLE_PREMIUM

    string internal constant GROUP_ENTITY_ADMINS = "Entity Admins";
    string internal constant GROUP_ENTITY_MANAGERS = "Entity Managers";
    string internal constant GROUP_APPROVED_USERS = "Approved Users";
    string internal constant GROUP_BROKERS = "Brokers";
    string internal constant GROUP_INSURED_PARTIES = "Insured Parties";
    string internal constant GROUP_UNDERWRITERS = "Underwriters";
    string internal constant GROUP_CAPITAL_PROVIDERS = "Capital Providers";
    string internal constant GROUP_CLAIMS_ADMINS = "Claims Admins";
    string internal constant GROUP_TRADERS = "Traders";
    string internal constant GROUP_SEGREGATED_ACCOUNTS = "Segregated Accounts";
    string internal constant GROUP_SERVICE_PROVIDERS = "Service Providers";
    string internal constant GROUP_ONBOARDING_APPROVERS = "Onboarding Approvers";
    string internal constant GROUP_TOKEN_HOLDERS = "Token Holders";
}
