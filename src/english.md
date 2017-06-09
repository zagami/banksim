
# Money Simulator

## Shortcuts

* You can press **n** to simulate one step
* You can press **r** to reset the simulation
* You can press **a** to toggle Autorun mode

## Assuptions of the simulation

- There is **1 central bank**
- There is a fixed number of **banks**
- Every bank has a random number of customers (**nonbanks**)
- All money is book money, there is **no cash** for simplicity
- Nonbanks have only 1 bank account (1 deposit and 1 savings account)
- Every customer has an *initial deposit*, this money is debt free and is issued by the central bank

every year the following steps are made:

choose all participants vs choose only random subset?
pay interst every year? to everybody? which sequence? 
 choose 2 random participants (state s, central bank cb, banks b, nonbanks nb)
 do the following transactions in random sequence:
 - pay interest for creditors if in debt
 - transaction of random amount

## Nonbanks
- nonbanks can make the following transactions:
  - pay interest to creditors (bank, nonbanks)
  - pay taxes
  - transaction to other nonbank or bank (economic activity)
  - redemption of bank loan (partial or complete)
  - invest money (private equity)
  - savings deposit
  - pay ROI (return on investment) on private equity

## Central Bank
- the central bank will provide as many loans as requested by banks
- loans are not secured by collaterals
- if a bank has not enough reserves to make the transaction it can take a loan from the central bank (prime rate) or from the target bank (libor rate), depending on which rate is lower. Interbank loans are preferred if rates are equal.

## Banks
- the interest rates for deposits and loans are the same for every bank
- overdrafts: a negative deposit is not possible, this would be equivalent to a loan
- the banks will provide as many loans as requested by customers
- loans are not secured by collaterals
- the libor rate is the same for every bank
- there is no upper limit for interbank loans 

- since the loans are not secured, a customer can always extend their loans by the remaining interest debt (compound interest)
- a bank cannot get bankrupt
- a bank can make the following transactions:
  - payment to nonbanks (salary, services etc)
  - invest money (shares of other banks or nonbanks)
  - pay ROI to nonbanks and other banks
    
## State
- the state has a bank account at the central bank
- the state can tax the nonbanks by income or wealth
- the state can provide a basic income to nonbanks
- the state can invest money in banks and nonbanks
