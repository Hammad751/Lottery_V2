// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IRandomNumberGenerator {

    function getRandomNumber() external;

    function viewLatestLotteryId() external view returns (uint256);

    function viewRandomResult() external view returns (uint32);
}

interface IPriceOracle {
    struct Observation {
        uint timestamp;
        uint price0Cumulative;
        uint price1Cumulative;
    }
    function pairObservations(address pairAddress) external view returns(Observation memory);
    function update(address tokenA, address tokenB) external;
    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint);
}

interface IBabyLottery {

    function buyTickets(uint256 _lotteryId, uint32[] calldata _ticketNumbers) external;

    function claimTickets(
        uint256 _lotteryId,
        uint256[] calldata _ticketIds,
        uint32[] calldata _brackets
    ) external;

    function closeLottery(uint256 _lotteryId) external;

    function drawFinalNumberAndMakeLotteryClaimable(
        uint256 _lotteryId,
        uint[6] calldata _bswPerBracket,
        uint[6] calldata _countTicketsPerBracket,
        bool _autoInjection
    ) external;

    /**
     * @notice Inject funds
     * @param _lotteryId: lottery id
     * @param _amount: amount to inject in BABY token
     * @dev Callable by operator
     */
    function injectFunds(uint256 _lotteryId, uint256 _amount) external;

    /**
     * @notice Start the lottery
     * @dev Callable by operator
     * @param _endTime: endTime of the lottery
     * @param _priceTicketInUSDT: price of a ticket in BABY
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks
     * @param _rewardsBreakdown: breakdown of rewards per bracket (must sum to 10,000)
     */
    function startLottery(
        uint256 _endTime,
        uint256 _priceTicketInUSDT,
        uint256 _discountDivisor,
        uint256[6] calldata _rewardsBreakdown
    ) external;

    /**
     * @notice View current lottery id
     */
    function viewCurrentLotteryId() external returns (uint256);

    function getCurrentTicketPriceInBABY(uint _lotteryId) external view returns(uint);
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IBabyloniaLottery {

    function buyTickets(uint256 _lotteryId, uint32[] calldata _ticketNumbers) external;
    function claimTickets(
        uint256 _lotteryId,
        uint256[] calldata _ticketIds,
        uint32[] calldata _brackets
    ) external;

    function closeLottery(uint256 _lotteryId) external;
    function drawFinalNumberAndMakeLotteryClaimable(uint256 _lotteryId, bool _autoInjection) external;

    function injectFunds(uint256 _lotteryId, uint256 _amount) external;
    function startLottery(
        uint256 _endTime,
        uint256 _priceTicketInBABY,
        uint256 _discountDivisor,
        uint256[6] calldata _rewardsBreakdown,
        uint256 _treasuryFee
    ) external;
    function viewCurrentLotteryId() external returns (uint256);
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

/** @title Baby Lottery.
 * @notice It is a contract for a lottery system using
 * randomness provided externally.
 */
contract BabyLottery is ReentrancyGuard, IBabyLottery, Ownable {
    using SafeERC20 for IERC20;

    address public injectorAddress;
    address public operatorAddress;
    address public treasuryAddress;
    address public burningAddress;  //Send tokens from every deposit to burn
    address public competitionAndRefAddress; //Send tokens from every deposit to referrals and competitions
    address public usdtTokenAddress;
    address public babyTokenAddress;

    uint256 public currentLotteryId;  
    uint256 public currentTicketId;    

    uint256 public burningShare = 1300; //1300: 13%
    uint256 public competitionAndRefShare = 700; //700: 7%

    uint256 public maxNumberTicketsPerBuyOrClaim = 100;

    uint256 public maxPriceTicketInBABY = 0.1 ether;
    uint256 public minPriceTicketInBABY = 0.005 ether;
    uint256 public maxDiffPriceUpdate = 1500; //Difference between old and new price given from oracle

    uint256 public pendingInjectionNextLottery;

    uint256 public constant MIN_DISCOUNT_DIVISOR = 300;
    // uint256 public constant MIN_LENGTH_LOTTERY = 4 hours - 5 minutes; // 4 hours
    uint256 public constant MIN_LENGTH_LOTTERY = 3 minutes;
    uint256 public constant MAX_LENGTH_LOTTERY = 4 days + 5 minutes; // 4 days


    IERC20 public babyToken;
    IRandomNumberGenerator public randomGenerator;
    IPriceOracle public priceOracle;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct Lottery {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 priceTicketInBABY;
        uint256 priceTicketInUSDT;
        uint256 discountDivisor;    //Must be 10000 for discount 4,99% for 500 tickets
        uint256[6] rewardsBreakdown; // 0: 1 matching number // 5: 6 matching numbers
        uint256[6] babyPerBracket;
        uint256[6] countWinnersPerBracket;
        uint256 firstTicketId;
        uint256 firstTicketIdNextLottery;
        uint256 amountCollectedInBABY;
        uint32 finalNumber;
    }

    struct Ticket {
        uint32 number;
        address owner;
    }

    // Mapping are cheaper than arrays
    mapping(uint256 => Lottery) private _lotteries;
    mapping(uint256 => Ticket) private _tickets;

    // Bracket calculator is used for verifying claims for ticket prizes
    mapping(uint32 => uint32) private _bracketCalculator;

    // Keep track of user ticket ids for a given lotteryId
    mapping(address => mapping(uint256 => uint256[])) private _userTicketIdsPerLotteryId;

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    modifier onlyOwnerOrInjector() {
        require((msg.sender == owner()) || (msg.sender == injectorAddress), "Not owner or injector");
        _;
    }

    event AdminTokenRecovery(address token, uint256 amount);
    event LotteryClose(uint256 indexed lotteryId, uint256 firstTicketIdNextLottery);
    event LotteryInjection(uint256 indexed lotteryId, uint256 injectedAmount);
    event LotteryOpen(
        uint256 indexed lotteryId,
        uint256 startTime,
        uint256 endTime,
        uint256 priceTicketInUSDT,
        uint256 firstTicketId,
        uint256 injectedAmount
    );
    event LotteryNumberDrawn(uint256 indexed lotteryId, uint256 finalNumber, uint256 countWinningTickets);
    event NewManagingAddresses(
        address operator,
        address treasury,
        address injector,
        address burningAddress,
        address competitionAndRefAddress
    );
    event NewRandomGenerator(address indexed randomGenerator);
    event NewPriceOracle(address oracle);
    event TicketsPurchase(address indexed buyer, uint256 indexed lotteryId, uint256 numberTickets);
    event TicketsClaim(address indexed claimer, uint256 amount, uint256 indexed lotteryId, uint256 numberTickets);

    // /**
    //  * @notice Constructor
    //  * @dev RandomNumberGenerator must be deployed prior to this contract
    //  * @param _bswTokenAddress: address of the BABY token
    //  * @param _usdtTokenAddress: address of the USDT token
    //  * @param _randomGeneratorAddress: address of the RandomGenerator contract used to work with ChainLink VRF
    //  * @param _priceOracleAddress: address of oracle
    //  */
    constructor(
        address _babyTokenAddress,
        address _usdtTokenAddress,
        address _randomGeneratorAddress,
        address _priceOracleAddress
    ) {
        babyToken = IERC20(_babyTokenAddress);
        babyTokenAddress = _babyTokenAddress;
        usdtTokenAddress = _usdtTokenAddress;
        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);
        priceOracle = IPriceOracle(_priceOracleAddress);

        // Initializes a mapping
        _bracketCalculator[0] = 1;
        _bracketCalculator[1] = 11;
        _bracketCalculator[2] = 111;
        _bracketCalculator[3] = 1111;
        _bracketCalculator[4] = 11111;
        _bracketCalculator[5] = 111111;
    }

    /**
     * @notice Buy tickets for the current lottery
     * @param _lotteryId: lotteryId
     * @param _ticketNumbers: array of ticket numbers between 1,000,000 and 1,999,999 TAKE CARE! NUMBERS IS INVERTED
     * @dev Callable by users
     */

    //  we have to pass lottery id and random number between 1,000,000 and 1,999,999 .
    function buyTickets(uint256 _lotteryId, uint32[] calldata _ticketNumbers)
        external
        override
        notContract
        nonReentrant
    {
        require(_ticketNumbers.length != 0, "No ticket specified");
        require(_ticketNumbers.length <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");

        require(_lotteries[_lotteryId].status == Status.Open, "Lottery is not open");
        require(block.timestamp < _lotteries[_lotteryId].endTime, "Lottery is over");

        // Update BABY price for _lotteryId
        _updateBABYPrice(_lotteryId);

        // Calculate number of BABY to this contract
        uint256 amountBABYToTransfer = _calculateTotalPriceForBulkTickets(
            _lotteries[_lotteryId].discountDivisor,
            _lotteries[_lotteryId].priceTicketInBABY,
            _ticketNumbers.length
        );

        // Transfer BABY tokens to this contract
        babyToken.safeTransferFrom(address(msg.sender), address(this), amountBABYToTransfer);

        // Increment the total amount collected for the lottery round
        _lotteries[_lotteryId].amountCollectedInBABY += amountBABYToTransfer;

        uint _currentTicketId = currentTicketId;
        for (uint256 i = 0; i < _ticketNumbers.length; i++) {
            uint32 thisTicketNumber = _ticketNumbers[i];
            uint thisCurrentTicketId = _currentTicketId++;
            require((thisTicketNumber >= 1000000) && (thisTicketNumber <= 1999999), "Outside range");

            _userTicketIdsPerLotteryId[msg.sender][_lotteryId].push(thisCurrentTicketId);
            _tickets[thisCurrentTicketId] = Ticket({number: thisTicketNumber, owner: msg.sender});
        }
        // Increase lottery ticket number
        currentTicketId += _ticketNumbers.length;

        emit TicketsPurchase(msg.sender, _lotteryId, _ticketNumbers.length);
    }

    /**
     * @notice Claim a set of winning tickets for a lottery
     * @param _lotteryId: lottery id
     * @param _ticketIds: array of ticket ids
     * @param _brackets: array of brackets for the ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(
        uint256 _lotteryId,
        uint256[] calldata _ticketIds,
        uint32[] calldata _brackets
    )
        external
        override
        notContract
        nonReentrant
    {
        require(_ticketIds.length == _brackets.length, "Not same length");
        require(_ticketIds.length != 0, "Length must be >0");
        require(_ticketIds.length <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");
        require(_lotteries[_lotteryId].status == Status.Claimable, "Lottery not claimable");

        // Initializes the rewardInBABYToTransfer
        uint256 rewardInBABYToTransfer;

        for (uint256 i = 0; i < _ticketIds.length; i++) {
            require(_brackets[i] < 6, "Bracket out of range"); // Must be between 0 and 5

            uint256 thisTicketId = _ticketIds[i];

            require(_lotteries[_lotteryId].firstTicketIdNextLottery > thisTicketId, "TicketId too high");
            require(_lotteries[_lotteryId].firstTicketId <= thisTicketId, "TicketId too low");
            require(msg.sender == _tickets[thisTicketId].owner, "Not the owner");

            // Update the lottery ticket owner to 0x address
            _tickets[thisTicketId].owner = address(0);

            uint256 rewardForTicketId = _calculateRewardsForTicketId(_lotteryId, thisTicketId, _brackets[i]);

            // Check user is claiming the correct bracket
            require(rewardForTicketId != 0, "No prize for this bracket");

            if (_brackets[i] != 5) {
                require(
                    _calculateRewardsForTicketId(_lotteryId, thisTicketId, _brackets[i] + 1) == 0,
                    "Bracket must be higher"
                );
            }

            // Increment the reward to transfer
            rewardInBABYToTransfer += rewardForTicketId;
        }

        // Transfer money to msg.sender
        babyToken.safeTransfer(msg.sender, rewardInBABYToTransfer);

        emit TicketsClaim(msg.sender, rewardInBABYToTransfer, _lotteryId, _ticketIds.length);
    }

    function getCurrentTicketPriceInBABY(uint _lotteryId) override external view returns(uint){
        return priceOracle.consult(
            usdtTokenAddress,
            _lotteries[_lotteryId].priceTicketInUSDT,
            babyTokenAddress
        );
    }

    /**
     * @notice Close lottery
     * @param _lotteryId: lottery id
     * @dev Callable by operator
     */
    function closeLottery(uint256 _lotteryId) external override onlyOperator nonReentrant {
        require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");
        require(block.timestamp > _lotteries[_lotteryId].endTime, "Lottery not over");
        _lotteries[_lotteryId].firstTicketIdNextLottery = currentTicketId;

        _lotteries[_lotteryId].status = Status.Close;

        // Request a random number from the generator based on a seed
        randomGenerator.getRandomNumber();

        emit LotteryClose(_lotteryId, currentTicketId);
    }

    // /**
    //  * @notice Draw the final number, calculate reward in BABY per group, and make lottery claimable
    //  * @param _lotteryId: lottery id
    //  * @param _autoInjection: reinjects funds into next lottery (vs. withdrawing all)
    //  * @param _babyPerBracket: distribution of winnings by bracket
    //  * @param _countTicketsPerBracket: total number of tickets in each bracket
    //  * @dev Callable by operator
    //  */
    function drawFinalNumberAndMakeLotteryClaimable(
        uint256 _lotteryId,
        uint[6] calldata _babyPerBracket,
        uint[6] calldata _countTicketsPerBracket,
        bool _autoInjection
    )
        external
        override
        onlyOperator
        nonReentrant
    {
        require(_lotteries[_lotteryId].status == Status.Close, "Lottery not close");
        require(_lotteryId == randomGenerator.viewLatestLotteryId(), "Numbers not drawn");
        require(_babyPerBracket.length == 6, 'Wrong babyPerBracket array size!');
        require(_countTicketsPerBracket.length == 6, 'Wrong countTicketsPerBracket array size!');

        //Withdraw burn, referrals and competitions pool

        uint amountToDistribute = _withdrawBurnAndCompetition(_lotteryId) + pendingInjectionNextLottery;
        pendingInjectionNextLottery = 0;

        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        uint32 finalNumber = randomGenerator.viewRandomResult();
        uint ticketsCountPerBrackets = 0;
        uint babySumPerBrackets = 0;
        for (uint i = 0; i < 6; i++){
            uint winningPoolPerBracket = _babyPerBracket[i] * _countTicketsPerBracket[i];
            ticketsCountPerBrackets += _countTicketsPerBracket[i];
            if(_countTicketsPerBracket[i] > 0){
                require(
                    winningPoolPerBracket >= (_lotteries[_lotteryId].rewardsBreakdown[i] * amountToDistribute) / 10000,
                    'Wrong amount on bracket'
                );
            }
            babySumPerBrackets += winningPoolPerBracket;
        }

        require(babySumPerBrackets <= amountToDistribute, 'Wrong brackets Total amount');

        _lotteries[_lotteryId].babyPerBracket = _babyPerBracket;
        _lotteries[_lotteryId].countWinnersPerBracket = _countTicketsPerBracket;

        // Update internal statuses for lottery
        _lotteries[_lotteryId].finalNumber = finalNumber;
        _lotteries[_lotteryId].status = Status.Claimable;

        // Transfer not winning BABY to treasury address if _autoInjection is false
        if (_autoInjection) {
            pendingInjectionNextLottery = amountToDistribute - babySumPerBrackets;
        } else {
            babyToken.safeTransfer(treasuryAddress, amountToDistribute - babySumPerBrackets);
        }

        emit LotteryNumberDrawn(currentLotteryId, finalNumber, ticketsCountPerBrackets);
    }

    /**
     * @notice Change the random generator
     * @dev The calls to functions are used to verify the new generator implements them properly.
     * It is necessary to wait for the VRF response before starting a round.
     * Callable only by the contract owner
     * @param _randomGeneratorAddress: address of the random generator
     */
    function changeRandomGenerator(address _randomGeneratorAddress) external onlyOwner {
        require(_lotteries[currentLotteryId].status == Status.Claimable, "Lottery not in claimable");

        // Request a random number from the generator based on a seed
        IRandomNumberGenerator(_randomGeneratorAddress).getRandomNumber();

        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        IRandomNumberGenerator(_randomGeneratorAddress).viewRandomResult();

        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);

        emit NewRandomGenerator(_randomGeneratorAddress);
    }

    /**
     * @notice Change price oracle
     * @param _priceOracleAddress: address for new price oracle contract
     * @dev Callable only by owner address
     */
    function changeOracle(address _priceOracleAddress) external onlyOwner {
        require(_lotteries[currentLotteryId].status == Status.Claimable, "Lottery not in claimable");
        priceOracle = IPriceOracle(_priceOracleAddress);

        emit NewPriceOracle(_priceOracleAddress);
    }

    /**
     * @notice Inject funds
     * @param _lotteryId: lottery id
     * @param _amount: amount to inject in BABY token
     * @dev Callable by owner or injector address
     */
    function injectFunds(uint256 _lotteryId, uint256 _amount) external override onlyOwnerOrInjector {
        require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");

        babyToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        _lotteries[_lotteryId].amountCollectedInBABY += _amount;

        emit LotteryInjection(_lotteryId, _amount);
    }

    /**
     * @notice Start the lottery
     * @dev Callable by operator
     * @param _endTime: endTime of the lottery
     * @param _priceTicketInUSDT: price of a ticket in USDT
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks
     * @param _rewardsBreakdown: breakdown of rewards per bracket (must sum to 10,000)
     */
    function startLottery(
        uint256 _endTime,
        uint256 _priceTicketInUSDT,
        uint256 _discountDivisor,
        uint256[6] calldata _rewardsBreakdown
    ) external override onlyOperator {
        require(
            (currentLotteryId == 0) || (_lotteries[currentLotteryId].status == Status.Claimable),
            "Not time to start lottery"
        );

        require(
            ((_endTime - block.timestamp) > MIN_LENGTH_LOTTERY) && ((_endTime - block.timestamp) < MAX_LENGTH_LOTTERY),
            "Lottery length outside of range"
        );

        //Calculation price in BABY
        uint256 _priceTicketInBABY = _getPriceInBABY(_priceTicketInUSDT);

        require(
            (_priceTicketInBABY >= minPriceTicketInBABY) && (_priceTicketInBABY <= maxPriceTicketInBABY),
            "Price ticket in BABY Outside of limits"
        );

        require(_discountDivisor >= MIN_DISCOUNT_DIVISOR, "Discount divisor too low");

        require(
            (_rewardsBreakdown[0] +
            _rewardsBreakdown[1] +
            _rewardsBreakdown[2] +
            _rewardsBreakdown[3] +
            _rewardsBreakdown[4] +
            _rewardsBreakdown[5]) == 10000,
            "Rewards must equal 10000"
        );

        currentLotteryId++;
        _lotteries[currentLotteryId] = Lottery({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: _endTime,
            priceTicketInBABY: _priceTicketInBABY,
            priceTicketInUSDT: _priceTicketInUSDT,
            discountDivisor: _discountDivisor,
            rewardsBreakdown: _rewardsBreakdown,
            babyPerBracket: [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
            countWinnersPerBracket: [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
            firstTicketId: currentTicketId,
            firstTicketIdNextLottery: currentTicketId,
            amountCollectedInBABY: 0,
            finalNumber: 0
        });

        emit LotteryOpen(
            currentLotteryId,
            block.timestamp,
            _endTime,
            _priceTicketInUSDT,
            currentTicketId,
            pendingInjectionNextLottery
        );
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev Only callable by owner.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(babyTokenAddress), "Cannot be BABY token");

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /*
     * @notice Set BABY price ticket upper/lower limit
     * @dev Only callable by owner
     * @param _minPriceTicketInBABY: minimum price of a ticket in BABY
     * @param _maxPriceTicketInBABY: maximum price of a ticket in BABY
     */
    function setMinAndMaxTicketPriceInBABY(uint256 _minPriceTicketInBSW, uint256 _maxPriceTicketInBSW)
        external
        onlyOwner
    {
        require(_minPriceTicketInBSW <= _maxPriceTicketInBSW, "minPrice must be < maxPrice");

        minPriceTicketInBABY = _minPriceTicketInBSW;
        maxPriceTicketInBABY = _maxPriceTicketInBSW;
    }

    /**
     * @notice Set max number of tickets
     * @dev Only callable by owner
     */
    function setMaxNumberTicketsPerBuy(uint256 _maxNumberTicketsPerBuy) external onlyOwner {
        require(_maxNumberTicketsPerBuy != 0, "Must be > 0");
        maxNumberTicketsPerBuyOrClaim = _maxNumberTicketsPerBuy;
    }

    /**
     * @notice Set burning and competitions shares
     * @dev Only callable by owner
     */
    function setBurningAndCompetitionShare(uint256 _burningShare, uint256 _competitionAndRefShare) external onlyOwner {
        require(_burningShare != 0 && _competitionAndRefShare != 0, "Must be > 0");
        require(_lotteries[currentLotteryId].status == Status.Claimable, "Lottery not in claimable");
        burningShare = _burningShare;
        competitionAndRefShare = _competitionAndRefShare;
    }

    /**
     * @notice Set max difference between old and new price when update from oracle
     * @dev Only callable by owner
     */
    function setMaxDiffPriceUpdate(uint256 _maxDiffPriceUpdate) external onlyOwner {
        require(_maxDiffPriceUpdate != 0, "Must be > 0");
        maxDiffPriceUpdate = _maxDiffPriceUpdate;
    }

    /**
     * @notice Set operator, treasury, and injector addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     * @param _treasuryAddress: address of the treasury
     * @param _injectorAddress: address of the injector
     * @param _burningAddress: address to collect burn tokens
     * @param _competitionAndRefAddress: address to distribute competitions and referrals shares
    */

    
    function setManagingAddresses(
        address _operatorAddress,
        address _treasuryAddress,
        address _injectorAddress,
        address _burningAddress,
        address _competitionAndRefAddress
    ) external onlyOwner {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(_treasuryAddress != address(0), "Cannot be zero address");
        require(_injectorAddress != address(0), "Cannot be zero address");
        require(_burningAddress != address(0), "Cannot be zero address");
        require(_competitionAndRefAddress != address(0), "Cannot be zero address");

        operatorAddress = _operatorAddress;
        treasuryAddress = _treasuryAddress;
        injectorAddress = _injectorAddress;
        burningAddress = _burningAddress;
        competitionAndRefAddress = _competitionAndRefAddress;

        emit NewManagingAddresses(
            _operatorAddress,
            _treasuryAddress,
            _injectorAddress,
            _burningAddress,
            _competitionAndRefAddress
        );
    }

    /**
     * @notice Calculate price of a set of tickets
     * @param _discountDivisor: divisor for the discount
     * @param _priceTicket price of a ticket (in BABY)
     * @param _numberTickets number of tickets to buy
    */
    function calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) external pure returns (uint256) {
        require(_discountDivisor >= MIN_DISCOUNT_DIVISOR, "Must be >= MIN_DISCOUNT_DIVISOR");
        require(_numberTickets != 0, "Number of tickets must be > 0");

        return _calculateTotalPriceForBulkTickets(_discountDivisor, _priceTicket, _numberTickets);
    }

    /**
     * @notice View current lottery id
     */
    function viewCurrentLotteryId() external view override returns (uint256) {
        return currentLotteryId;
    }

    /**
     * @notice View lottery information
     * @param _lotteryId: lottery id
     */
    function viewLottery(uint256 _lotteryId) external view returns (Lottery memory) {
        return _lotteries[_lotteryId];
    }

    /**
     * @notice View ticker statuses and numbers for an array of ticket ids
     * @param _ticketIds: array of _ticketId
     */
    function viewNumbersAndStatusesForTicketIds(uint256[] calldata _ticketIds)
        external
        view
        returns (uint32[] memory, bool[] memory)
    {
        uint256 length = _ticketIds.length;
        uint32[] memory ticketNumbers = new uint32[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            ticketNumbers[i] = _tickets[_ticketIds[i]].number;
            if (_tickets[_ticketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                ticketStatuses[i] = false;
            }
        }

        return (ticketNumbers, ticketStatuses);
    }

    /**
     * @notice View rewards for a given ticket, providing a bracket, and lottery id
     * @dev Computations are mostly offchain. This is used to verify a ticket!
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     * @param _bracket: bracket for the ticketId to verify the claim and calculate rewards
     */
    function viewRewardsForTicketId(
        uint256 _lotteryId,
        uint256 _ticketId,
        uint32 _bracket
    ) external view returns (uint256) {
        // Check lottery is in claimable status
        if (_lotteries[_lotteryId].status != Status.Claimable) {
            return 0;
            }

        // Check ticketId is within range
        if (
            (_lotteries[_lotteryId].firstTicketIdNextLottery < _ticketId) &&
            (_lotteries[_lotteryId].firstTicketId >= _ticketId)
        ){
            return 0;
        }
        return _calculateRewardsForTicketId(_lotteryId, _ticketId, _bracket);
    }

    /**
     * @notice View user ticket ids, numbers, and statuses of user for a given lottery
     * @param _user: user address
     * @param _lotteryId: lottery id
     * @param _cursor: cursor to start where to retrieve the tickets
     * @param _size: the number of tickets to retrieve
     */
    function viewUserInfoForLotteryId(
        address _user,
        uint256 _lotteryId,
        uint256 _cursor,
        uint256 _size
    ) external view returns (
        uint256[] memory,
        uint32[] memory,
        bool[] memory,
        uint256
    ){
        uint256 length = _size;
        uint256 numberTicketsBoughtAtLotteryId = _userTicketIdsPerLotteryId[_user][_lotteryId].length;

        if (length > (numberTicketsBoughtAtLotteryId - _cursor)) {
            length = numberTicketsBoughtAtLotteryId - _cursor;
        }

        uint256[] memory lotteryTicketIds = new uint256[](length);
        uint32[] memory ticketNumbers = new uint32[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            lotteryTicketIds[i] = _userTicketIdsPerLotteryId[_user][_lotteryId][i + _cursor];
            ticketNumbers[i] = _tickets[lotteryTicketIds[i]].number;

            // True = ticket claimed
            if (_tickets[lotteryTicketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                // ticket not claimed (includes the ones that cannot be claimed)
                ticketStatuses[i] = false;
            }
        }
        return (lotteryTicketIds, ticketNumbers, ticketStatuses, _cursor + length);
    }

    /**
     * @notice Withdraw burn, referrals and competitions pool
     * @param _lotteryId: lottery Id
     * @dev Return collected amount without withdrawal burn ref and comp sum
     */
    function _withdrawBurnAndCompetition(uint _lotteryId) internal returns(uint){
        require(_lotteries[_lotteryId].status == Status.Close, "Lottery not close");

        uint collectedAmount = _lotteries[_lotteryId].amountCollectedInBABY;
        uint burnSum = (collectedAmount * burningShare) / 10000 ;
        uint competitionAndRefSum = (collectedAmount * competitionAndRefShare) / 10000 ;
        babyToken.safeTransfer(burningAddress, burnSum);
        babyToken.safeTransfer(competitionAndRefAddress, competitionAndRefSum);
        return (collectedAmount - burnSum - competitionAndRefSum);
    }

    /**
     * @notice Update BABY price for lotteryID
     */
    function _updateBABYPrice(uint256 _lotteryId) private {
        uint oldPriceInBABY = _lotteries[_lotteryId].priceTicketInBABY;
        uint newPriceInBABY = priceOracle.consult(usdtTokenAddress, _lotteries[_lotteryId].priceTicketInUSDT, babyTokenAddress);

        require(_chekPriceDifference(newPriceInBABY, oldPriceInBABY, maxDiffPriceUpdate), 'Oracle give invalid price');
        _lotteries[_lotteryId].priceTicketInBABY = newPriceInBABY;
    }

    /**
     * @notice Check difference between old and new prices
     */
    function _chekPriceDifference(uint256 _newPrice, uint256 _oldPrice, uint _maxDiff) internal pure returns(bool diff){
        require(_newPrice > 0 && _oldPrice > 0, 'Wrong prices given');
        if(_newPrice > _oldPrice){
            diff = (((_newPrice * 10000) / _oldPrice) - 10000) <= _maxDiff;
        } else {
            diff = (((_oldPrice * 10000) / _newPrice) - 10000) <= _maxDiff;
        }
    }

    /**
     * @notice Get current exchange rate BABY/USDT from oracle
     */
    function _getPriceInBABY(uint256 _priceInUSDT) internal view returns(uint256) {
        return priceOracle.consult(usdtTokenAddress, _priceInUSDT, babyTokenAddress);
    }

    /**
     * @notice Calculate rewards for a given ticket
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     * @param _bracket: bracket for the ticketId to verify the claim and calculate rewards
     */
    function _calculateRewardsForTicketId(
        uint256 _lotteryId,
        uint256 _ticketId,
        uint32 _bracket
    ) internal view returns (uint256) {
        // Retrieve the winning number combination
        uint32 userNumber = _lotteries[_lotteryId].finalNumber;

        // Retrieve the user number combination from the ticketId
        uint32 winningTicketNumber = _tickets[_ticketId].number;

        // Apply transformation to verify the claim provided by the user is true
        uint32 transformedWinningNumber = _bracketCalculator[_bracket] +
        (winningTicketNumber % (uint32(10)**(_bracket + 1)));

        uint32 transformedUserNumber = _bracketCalculator[_bracket] + (userNumber % (uint32(10)**(_bracket + 1)));

        // Confirm that the two transformed numbers are the same, if not throw
        if (transformedWinningNumber == transformedUserNumber) {
            return _lotteries[_lotteryId].babyPerBracket[_bracket];
        } else {
            return 0;
        }
    }

    /**
     * @notice Calculate final price for bulk of tickets
     * @param _discountDivisor: divisor for the discount (the smaller it is, the greater the discount is)
     * @param _priceTicket: price of a ticket
     * @param _numberTickets: number of tickets purchased
     */
    function _calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) internal pure returns (uint256) {
        return (_priceTicket * _numberTickets * (_discountDivisor + 1 - _numberTickets)) / _discountDivisor;
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}