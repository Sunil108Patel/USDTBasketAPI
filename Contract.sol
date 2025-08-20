/**
 *Submitted for verification at polygonscan.com on 2025-08-17
*/

/**
 *Submitted for verification at polygonscan.com on 2025-08-04
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: usdtbasket.sol


pragma solidity ^0.8.20;



contract USDT_Basket is Ownable {

    // Address: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F
    IERC20 public immutable usdtToken;

    // Structure to store user information.
    struct User {
        bool isJoined;
        address sponsor;
        uint256 totalDeposits;
        mapping(uint256 => uint256) packageDeposits; // packageId => amount
    }

    // Structure for investment packages.
    struct Package {
        uint256 id;
        uint256 price;
        bool isJoiningPack;
        bool isActive;
    }

    mapping(address => User) public users;

    mapping(uint256 => Package) public packages;
    mapping(uint256 => bool) public withdrawalRequestIds;
    uint256 nextPackageId = 1;

    // --- Events ---

    event UserJoined(address indexed user, address indexed sponsor, uint256 indexed packageId, uint256 amount);

    event DepositMade(address indexed user, uint256 indexed packageId, uint256 amount);

    event TokensSent(address toAddress, uint256 amount, uint256 requestId);

    event PackageAdded(uint256 indexed packageId, uint256 price);

    event PackageStatusUpdated(uint256 indexed packageId, bool isActive);

    constructor() Ownable(msg.sender) {
        usdtToken = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        _initPackages();
    }

    
    function _initPackages() internal {
        addPackage(4 * 10**6, true);   // Package 1 (Joining)
        addPackage(4 * 10**6, false);  // Package 2
        addPackage(8 * 10**6, false);  // Package 3
        addPackage(16 * 10**6, false); // Package 4
        addPackage(32 * 10**6, false); // Package 5
        addPackage(64 * 10**6, false); // Package 6
        addPackage(128 * 10**6, false);// Package 7
        addPackage(256 * 10**6, false);// Package 8
        addPackage(512 * 10**6, false);// Package 9
        addPackage(1024 * 10**6, false);// Package 10
        addPackage(2048 * 10**6, false);// Package 11
        addPackage(4096 * 10**6, false);// Package 12
        addPackage(6000 * 10**6, false);// Package 13
        addPackage(7000 * 10**6, false);// Package 14
        addPackage(8000 * 10**6, false);// Package 15
        addPackage(9000 * 10**6, false);// Package 16
    }

    function Join(address _sponsorAddress, uint256 _packageId, uint256 _amount) external {
        require(!users[msg.sender].isJoined, "User has already joined");
        // require(users[_sponsorAddress].isJoined || _sponsorAddress == owner(), "Sponsor not found");
        require(_packageId > 0 && _packageId < nextPackageId, "Package does not exist");
        
        Package storage selectedPackage = packages[_packageId];
        require(selectedPackage.isActive, "Package is not active");
        require(selectedPackage.isJoiningPack, "Select a joining package");
        require(_amount == selectedPackage.price, "Amount does not match package price");

        uint256 initialBalance = usdtToken.balanceOf(address(this));
        usdtToken.transferFrom(msg.sender, address(this), _amount);
        uint256 finalBalance = usdtToken.balanceOf(address(this));
        require(finalBalance == initialBalance + _amount, "Token transfer failed");

        User storage newUser = users[msg.sender];
        newUser.isJoined = true;
        newUser.sponsor = _sponsorAddress;
        newUser.totalDeposits += _amount;
        newUser.packageDeposits[_packageId] += _amount;

        // --- Event ---
        emit UserJoined(msg.sender, _sponsorAddress, _packageId, _amount);
    }

    function Deposit(uint256 _packageId, uint256 _amount) external {
        // require(users[msg.sender].isJoined, "User has not joined");
        require(_packageId > 0 && _packageId < nextPackageId, "Package does not exist");

        Package storage selectedPackage = packages[_packageId];
        require(selectedPackage.isActive, "Package is not active");
        require(!selectedPackage.isJoiningPack, "Select a topup package");
        require(_amount == selectedPackage.price, "Amount does not match package price");
        
        uint256 initialBalance = usdtToken.balanceOf(address(this));
        usdtToken.transferFrom(msg.sender, address(this), _amount);
        uint256 finalBalance = usdtToken.balanceOf(address(this));
        require(finalBalance == initialBalance + _amount, "Token transfer failed");

        User storage currentUser = users[msg.sender];
        currentUser.totalDeposits += _amount;
        currentUser.packageDeposits[_packageId] += _amount;

        emit DepositMade(msg.sender, _packageId, _amount);
    }

    function SendTokens(address _toAddress, uint256 _amount, uint256 _requestId) external onlyOwner {
        require(!withdrawalRequestIds[_requestId], "Request ID already processed");
        require(usdtToken.balanceOf(address(this)) >= _amount, "Insufficient contract balance");
        require(_toAddress != address(0), "Invalid recipient address");
        require(_amount > 0, "Amount must be greater than zero");
        withdrawalRequestIds[_requestId] = true;
        usdtToken.transfer(_toAddress, _amount);

        emit TokensSent(_toAddress, _amount, _requestId);
    }

    function addPackage(uint256 _price, bool isJoiningPack) public onlyOwner {
        require(_price > 0, "Price must be positive");
        uint256 packageId = nextPackageId;
        packages[packageId] = Package({
            id: packageId,
            price: _price,
            isActive: true,
            isJoiningPack: isJoiningPack
        });
        nextPackageId++;
        emit PackageAdded(packageId, _price);
    }

    function updatePackageStatus(uint256 _packageId, bool _isActive) external onlyOwner {
        require(_packageId > 0 && _packageId < nextPackageId, "Package does not exist");
        packages[_packageId].isActive = _isActive;
        emit PackageStatusUpdated(_packageId, _isActive);
    }
    
    function getUserPackageDeposit(address _user, uint256 _packageId) external view returns (uint256) {
        return users[_user].packageDeposits[_packageId];
    }
}