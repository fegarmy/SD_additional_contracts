pragma solidity ^0.8.13;
// SPDX-License-Identifier: UNLICENSED
// Important you might want to run it with a high optimisation to avoid paying big gas fees if you have a lot of users to do!!!

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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


contract claimableAirdrop is Ownable,ReentrancyGuard {
    //change this part only
    address private _tokenAddress;

    uint256 public remainingPersonsToClaim = 0;
    uint256 public toDistribute = 0;
    bool public open = false;
    uint256 public startTime = block.timestamp;
    mapping (address => bool) private _isParticipant;

    function changeTokenAddress(address newaddress)external onlyOwner{
        require(remainingPersonsToClaim == 0 || block.timestamp > 1209600 + startTime ,"There are still persons that need to claim the presale or 2 weeks have not passed");
        _tokenAddress = newaddress;
    }

    function isParticipant(address user)  view external returns(bool){
        return _isParticipant[user];
    }

    function registerOneUser(address user) external onlyOwner{
        require(!open,"Airdrop is already close");
        if(!_isParticipant[user]){
            return;
        }
        remainingPersonsToClaim += 1;
        _isParticipant[user] = true;
    }
    function registerMultiple(address[] calldata _addresses) external onlyOwner{
        //May need to be split if not enough gas
        require(!open,"Airdrop is already close");
        for (uint i=0; i<_addresses.length; i++) {
            if(!_isParticipant[_addresses[i]]){
                continue;
            }
            _isParticipant[_addresses[i]] = true;
        }
        remainingPersonsToClaim += _addresses.length;
    }
    function claimAirdrop(address user)   external nonReentrant{
        require(open,"Airdrop is not yet open");
        require(_isParticipant[address(msg.sender)],"You are not registered in the airdrop sorry. (Or have already claimed once)");
        uint256 currentamount = toDistribute/remainingPersonsToClaim;
        bool xfer = IERC20(_tokenAddress).transfer(address(msg.sender), currentamount);
        require(xfer, "ERR_ERC20_FALSE");
        _isParticipant[address(msg.sender)] = false;
        remainingPersonsToClaim -= 1;
        toDistribute -= currentamount;
    }
    function releaseAirdop() external onlyOwner{
        open = true;
        startTime = block.timestamp;
        toDistribute = IERC20(_tokenAddress).balanceOf(address(this));
    }
    function getLeftOver() external onlyOwner nonReentrant{
        uint256 amt = LeftOverAvaillable();
        bool xfer = IERC20(_tokenAddress).transfer(address(msg.sender), amt);
        require(xfer, "ERR_ERC20_FALSE");
    }
    function LeftOverAvaillable() public view returns(uint256){
        if(remainingPersonsToClaim == 0){
            return  IERC20(_tokenAddress).balanceOf(address(this));
        }
        return IERC20(_tokenAddress).balanceOf(address(this)) - toDistribute;
         
    }
    
    

}

