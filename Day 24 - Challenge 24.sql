
# DAY 24 - Challenge 24

# TRANSACTION MANAGEMENT & ACID PROPERTIES

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

CALL transfer_money(1, 2, 2000);  -- This should trigger "Insufficient Balance"

CALL transfer_money(1, 2, 500);

# Check the transactions log
SELECT * FROM transactions;
SELECT * FROM accounts;

# Set the isolation level to READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;