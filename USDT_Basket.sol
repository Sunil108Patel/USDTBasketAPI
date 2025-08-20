// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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

    event TokensSent(address[] toAddresses, uint256[] amounts, uint256[] requestIds);
    
    event PackageAdded(uint256 indexed packageId, uint256 price);

    event PackageStatusUpdated(uint256 indexed packageId, bool isActive);

    constructor(address _usdtTokenAddress) Ownable(msg.sender) {
        require(_usdtTokenAddress != address(0), "Invalid USDT token address");
        usdtToken = IERC20(_usdtTokenAddress);
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

    function SendTokens(address[] calldata _toAddresses, uint256[] calldata _amounts, uint256[] calldata _requestIds) external onlyOwner {
        require(_toAddresses.length > 0, "Recipient array is empty");
        require(_toAddresses.length == _amounts.length, "Array length mismatch (addresses vs amounts)");
        require(_toAddresses.length == _requestIds.length, "Array length mismatch (addresses vs requestIds)");

        uint256 totalAmountToSend = 0;
        for (uint256 i = 0; i < _amounts.length; i++) {
            totalAmountToSend += _amounts[i];
        }
        require(usdtToken.balanceOf(address(this)) >= totalAmountToSend, "Insufficient contract balance");

        for (uint256 i = 0; i < _toAddresses.length; i++) {
            require(_toAddresses[i] != address(0), "Invalid recipient address");
            require(_amounts[i] > 0, "Amount must be greater than zero");
            withdrawalRequestIds[_requestIds[i]] = true;
            usdtToken.transfer(_toAddresses[i], _amounts[i]);
        }

        emit TokensSent(_toAddresses, _amounts, _requestIds);
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
