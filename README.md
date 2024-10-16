# MySQL---Transactional-Management-and-ACID-Properties

# DAY 24 - Challenge 24

# TRANSACTION MANAGEMENT & ACID PROPERTIES

As part of a 75-day data analysis challenge, this work on MySQL covers Transactional Management and ACID properties

USE Challenge;

# Create the accounts table
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    balance DECIMAL(10, 2)
);

# Insert initial account balances
INSERT INTO accounts (account_id, customer_name, balance) VALUES
(1, 'Alice', 1000.00),
(2, 'Bob', 1500.00);

# Create the transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account INT,
    to_account INT,
    amount DECIMAL(10, 2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

# Create a stored procedure for money transfer
CREATE PROCEDURE transfer_money(
	IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(10,2)
)
BEGIN
	DECLARE current_balance DECIMAL(10, 2);

    -- Start the transaction
    START TRANSACTION;

    -- Check the balance of the source account
    SELECT balance INTO current_balance
    FROM accounts
    WHERE account_id = from_account;

    -- Check if there is enough balance
    IF current_balance < amount THEN
        -- If insufficient balance, rollback the transaction
        ROLLBACK;
        SELECT 'Insufficient Balance' AS message;
    ELSE    
        -- Deduct from the source account
        UPDATE accounts
        SET balance = balance - amount
        WHERE account_id = from_account;

        -- Add to the target account
        UPDATE accounts
        SET balance = balance + amount
        WHERE account_id = to_account;

        -- Log the transaction
        INSERT INTO transactions (from_account, to_account, amount)
        VALUES (from_account, to_account, amount);

        -- Commit the transaction
        COMMIT;
        SELECT 'Transaction Successful' as message;
    END IF;
    
END $$

DELIMITER ;

# Call the stored procedure to transfer money
CALL transfer_money(1, 2, 500);


![Day 24](https://github.com/user-attachments/assets/1f766d72-622a-4ea3-9ff0-041487132a84)


CALL transfer_money(1, 2, 2000);  -- This should trigger "Insufficient Balance"


![Day 24 II](https://github.com/user-attachments/assets/975bf31a-81b2-46fb-939a-892a39a0b956)


CALL transfer_money(1, 2, 500);


![Day 24 III](https://github.com/user-attachments/assets/92aaf9e3-5b0c-4d2c-a2db-698b675cfc44)


# Check the transactions log
SELECT * FROM transactions;


![Day 24 IV](https://github.com/user-attachments/assets/8dad1834-e5c7-4917-a136-c231f05bfec5)


SELECT * FROM accounts;


![Day 24 V](https://github.com/user-attachments/assets/f37aea6b-a7db-4a4e-8ffa-3dd0f54cdd53)



# Set the isolation level to READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
