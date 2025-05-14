--Transactions #######################################################

/*
	Key Points
	----------
1.Our database is most vulnerable to damages while we or someone else is changing it.

2.If a software or hardware failure occurs while the change is in progress, a databae may be left in an indeterminate state..

3.A transaction is a list of commands that we want to run on our database to make changes on informations.

4.A transactions bundles multiple steps or operations into a single, All - or - nothing operations

5.Sql protects our database by restricting opearations that can change it so they can occur only within transactions

6.There are four main transactions commands, that protect from harrd. Both accidental and intentional
	-COMMIT
	-ROLL BACK
	-GRANT
	-REVOKE

7. Its possible for a harware or software problem to occure and as a result your database is susceptible to damage.

8. To minimize the chances of damage, teh dbms close the window of vulnerability as much as possible by performing all 
	operations that affect the database within a transaction and then coimmiting all these changes / operations at once
	at the end of the transaction

9.In a multi user system, database corruption or incorrect results are possible even if no hardware or software failure 
	occur. Interactions between two or more users who access the same table at the same time can cause serious data 
	issues and more. By restricting changes so that they occur only within TRANSACTIONS, sql address these problems 
	accordingly

*/


--lets create a sample table

CREATE TABLE IF NOT EXISTS accounts(
	account_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	balance INTEGER NOT NULL
)


--lets insert some data 

INSERT INTO accounts (name ,balance)
VALUES
	('Adam',100),
	('Bob',100),
	('Linda',100);


--in  background postgres is adding BEGIN in start of the transactions
SELECT *
FROM accounts;
--and at the end postgres will be adding a commit to the end of the query


BEGIN TRANSACTION;


	UPDATE accounts
	SET balance = balance - 50
	WHERE name = 'Adam';
	
	SELECT * FROM accounts;
	
ROLLBACK;

COMMIT;

--How to fix a transaction crash ######################################################################

BEGIN TRANSACTION;

	UPDATE accounts
	SET balance = balance + 50
	WHERE name = 'Adam';

	SELECT * FROM accounts;

COMMIT TRANSACTION;


--save point ###################################################################
/*
	1. Simple rollback and commit statments enable us to write or undo an entire transaction
		However we might want sometimes a support for a rollback of partial transaction

	2. to support the rollback of partial transaction, we must put placeholders at strategic
		location of the transaction block Thus, if a rollback is required, you can read back
		on the said placeholder.
	3. In PostgreSQL these place holders are called 'savepoints'

*/


--using a save point with transaction ##############################################################

SELECT *
FROM accounts;

BEGIN TRANSACTION;
	UPDATE accounts
	SET balance = balance + 60
	WHERE name = 'Bob';

	SAVEPOINT first_update;

	UPDATE accounts
	SET balance = balance - 120
	WHERE name = 'Adam';

	SELECT *
	FROM accounts;

	ROLLBACK TO
COMMIT TRANSACTION;

SELECT *
FROM accounts;


ROLLBACK TO first_update;
	