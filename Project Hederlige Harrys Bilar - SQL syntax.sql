
-- Tentamen SQL 2 (Ottilia Pettersson)

-- Creates Database

USE master
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'HederligeHarrysbilar')
BEGIN
    ALTER DATABASE HederligeHarrysbilar SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE HederligeHarrysbilar
END;

CREATE DATABASE HederligeHarrysbilar
GO

USE HederligeHarrysbilar
GO

-- Creates tables in the database

CREATE TABLE Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(25) NOT NULL UNIQUE,
    RoleDescription VARCHAR(255)
)

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
	RoleID INT NOT NULL,
    FirstName NVARCHAR(25) NOT NULL,
    LastName NVARCHAR(25) NOT NULL,
    Email NVARCHAR(50) NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(25),
    Address NVARCHAR(50),
    PostalCode NVARCHAR(25),
    Country NVARCHAR(25),
    City NVARCHAR(25),
    IsVerified BIT DEFAULT 0,
    IsLocked BIT DEFAULT 0,
    PasswordHash NVARCHAR(100) NOT NULL,
    PasswordSalt NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
	FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
)

CREATE NONCLUSTERED INDEX IX_Users_UserID_IsLocked
ON Users (UserID, IsLocked)

CREATE NONCLUSTERED INDEX IX_Users_Email
ON Users (Email)

CREATE TABLE UserRole (
    UserRoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleID INT NOT NULL,
    UserID INT NOT NULL,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
)

CREATE TABLE PasswordReset (
    ResetID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ResetToken UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CreatedAt DATETIME DEFAULT GETDATE(),
    ExpiryAt AS DATEADD(HOUR, 24, CreatedAt),
	StatusMessage NVARCHAR (255),
	Statuscode INT,
	IsUsed BIT NOT NULL DEFAULT (0),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
)

CREATE NONCLUSTERED INDEX IX_PasswordReset_UserID_Token
ON PasswordReset (UserID, ResetToken)

CREATE TABLE LoginAttempts (
    AttemptID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    IPAdress NVARCHAR(50) NULL, 
    AttemptTime DATETIME DEFAULT GETDATE(),
    Success BIT NOT NULL,
	Email NVARCHAR (50),
	Statuscode INT,
	StatusMessage NVARCHAR (255)
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
)
GO

CREATE NONCLUSTERED INDEX IX_LoginAttempts_UserID_Success
ON LoginAttempts (UserID, Success, AttemptTime)

CREATE NONCLUSTERED INDEX IX_LoginAttempts_AttemptTime
ON LoginAttempts (AttemptTime)

INSERT INTO Role
(RoleName)
 
VALUES 
('Admin'),
('Customer')
 
GO
 
-- Creates a new user and generating a unique salt and hashing too the password

CREATE OR ALTER PROCEDURE Newuser
	@RoleID INT,
    @FirstName NVARCHAR(25),
    @LastName NVARCHAR(25),
    @Email NVARCHAR(50),
    @PhoneNumber NVARCHAR(25),
    @Address NVARCHAR(50),
    @PostalCode NVARCHAR(10),
    @Country NVARCHAR(25),
    @City NVARCHAR(25),
    @Password NVARCHAR(100)

AS
BEGIN
	DECLARE @Salt NVARCHAR(100)
	DECLARE @PasswordHash NVARCHAR(100)

BEGIN TRY
	SET @Salt = CONVERT(NVARCHAR(100), NEWID())
	SET @PasswordHash = CONVERT(NVARCHAR(100), HASHBYTES('SHA2_256', @Password + @Salt), 1)

	INSERT INTO Users (RoleID, FirstName, LastName, Email, PhoneNumber, Address, PostalCode, Country, City, PasswordHash, PasswordSalt)
	VALUES (@RoleID, @FirstName, @LastName, @Email, @PhoneNumber, @Address, @PostalCode, @Country, @City, @PasswordHash, @Salt)

	PRINT 'User created successfully'
END TRY

BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
	DECLARE @ErrorState INT = ERROR_STATE()
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH

END
GO

EXEC Newuser
	@RoleID = 1,
    @FirstName = 'Erik',
    @LastName = 'Andersson',
    @Email = 'erik.andersson@email.com',
    @PhoneNumber = '0701234567',
    @Address = 'Storgatan 12',
    @PostalCode = '11122',
    @Country = 'Sverige',
    @City = 'Stockholm',
    @Password = 'ErikPassword123!'

EXEC Newuser 
	@RoleID = 1,
    @FirstName = 'Anna',
    @LastName = 'Johansson',
    @Email = 'anna.johansson@email.com',
    @PhoneNumber = '0709876543',
    @Address = 'Sveavägen 45',
    @PostalCode = '11322',
    @Country = 'Sverige',
    @City = 'Stockholm',
    @Password = 'AnnaPassword456!'

EXEC Newuser 
	@RoleID = 1,
    @FirstName = 'Lars',
    @LastName = 'Karlsson',
    @Email = 'lars.karlsson@email.com',
    @PhoneNumber = '0733216789',
    @Address = 'Kungsgatan 89',
    @PostalCode = '11455',
    @Country = 'Sverige',
    @City = 'Göteborg',
    @Password = 'LarsPassword789!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Maria',
    @LastName = 'Nilsson',
    @Email = 'maria.nilsson@email.com',
    @PhoneNumber = '0767654321',
    @Address = 'Drottninggatan 4',
    @PostalCode = '12345',
    @Country = 'Sverige',
    @City = 'Malmö',
    @Password = 'MariaPassword321!'

EXEC Newuser
	@RoleID = 2,
    @FirstName = 'Olof',
    @LastName = 'Berg',
    @Email = 'olof.berg@email.com',
    @PhoneNumber = '0721239988',
    @Address = 'Vasagatan 3',
    @PostalCode = '14121',
    @Country = 'Sverige',
    @City = 'Uppsala',
    @Password = 'OlofPassword654!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Karin',
    @LastName = 'Eriksson',
    @Email = 'karin.eriksson@email.com',
    @PhoneNumber = '0735671234',
    @Address = 'Södervägen 22',
    @PostalCode = '11822',
    @Country = 'Sverige',
    @City = 'Stockholm',
    @Password = 'KarinPassword987!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Johan',
    @LastName = 'Lindberg',
    @Email = 'johan.lindberg@email.com',
    @PhoneNumber = '0709988776',
    @Address = 'Östra Hamngatan 7',
    @PostalCode = '41109',
    @Country = 'Sverige',
    @City = 'Göteborg',
    @Password = 'JohanPassword654!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Emma',
    @LastName = 'Persson',
    @Email = 'emma.persson@email.com',
    @PhoneNumber = '0723344556',
    @Address = 'Norra Vägen 14',
    @PostalCode = '90123',
    @Country = 'Sverige',
    @City = 'Umeå',
    @Password = 'EmmaPassword234!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Henrik',
    @LastName = 'Svensson',
    @Email = 'henrik.svensson@email.com',
    @PhoneNumber = '0706655443',
    @Address = 'Järnvägsgatan 32',
    @PostalCode = '75222',
    @Country = 'Sverige',
    @City = 'Uppsala',
    @Password = 'HenrikPassword567!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Linda',
    @LastName = 'Gustafsson',
    @Email = 'linda.gustafsson@email.com',
    @PhoneNumber = '0734567890',
    @Address = 'Fiskargatan 11',
    @PostalCode = '21456',
    @Country = 'Sverige',
    @City = 'Malmö',
    @Password = 'LindaPassword876!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Andreas',
    @LastName = 'Blom',
    @Email = 'andreas.blom@email.com',
    @PhoneNumber = '0737788991',
    @Address = 'Parkvägen 33',
    @PostalCode = '54111',
    @Country = 'Sverige',
    @City = 'Västerås',
    @Password = 'AndreasPassword345!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Sofia',
    @LastName = 'Hedlund',
    @Email = 'sofia.hedlund@email.com',
    @PhoneNumber = '0761122334',
    @Address = 'Tegelbacken 12',
    @PostalCode = '55667',
    @Country = 'Sverige',
    @City = 'Örebro',
    @Password = 'SofiaPassword654!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Niklas',
    @LastName = 'Åberg',
    @Email = 'niklas.aberg@email.com',
    @PhoneNumber = '0709873211',
    @Address = 'Skogsvägen 6',
    @PostalCode = '33123',
    @Country = 'Sverige',
    @City = 'Jönköping',
    @Password = 'NiklasPassword234!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Evelina',
    @LastName = 'Holm',
    @Email = 'evelina.holm@email.com',
    @PhoneNumber = '0731122334',
    @Address = 'Ängsgatan 8',
    @PostalCode = '44566',
    @Country = 'Sverige',
    @City = 'Linköping',
    @Password = 'EvelinaPassword876!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Marcus',
    @LastName = 'Engström',
    @Email = 'marcus.engstrom@email.com',
    @PhoneNumber = '0765544332',
    @Address = 'Huvudgatan 44',
    @PostalCode = '33444',
    @Country = 'Sverige',
    @City = 'Karlstad',
    @Password = 'MarcusPassword987!'

EXEC Newuser 
	@RoleID = 2,	
    @FirstName = 'Ida',
    @LastName = 'Wiklund',
    @Email = 'ida.wiklund@email.com',
    @PhoneNumber = '0702233445',
    @Address = 'Torpvägen 18',
    @PostalCode = '78901',
    @Country = 'Sverige',
    @City = 'Sundsvall',
    @Password = 'IdaPassword123!'

EXEC Newuser
	@RoleID = 2,
    @FirstName = 'Patrik',
    @LastName = 'Ström',
    @Email = 'patrik.strom@email.com',
    @PhoneNumber = '0734433221',
    @Address = 'Fjärdvägen 27',
    @PostalCode = '90222',
    @Country = 'Sverige',
    @City = 'Luleå',
    @Password = 'PatrikPassword234!'

EXEC Newuser 
	@RoleID = 2,
	@FirstName = 'Camilla',
    @LastName = 'Nord',
    @Email = 'camilla.nord@email.com',
    @PhoneNumber = '0709988112',
    @Address = 'Hamngatan 19',
    @PostalCode = '10101',
    @Country = 'Sverige',
    @City = 'Stockholm',
    @Password = 'CamillaPassword345!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Simon',
    @LastName = 'Lindqvist',
    @Email = 'simon.lindqvist@email.com',
    @PhoneNumber = '0723345678',
    @Address = 'Fabriksgatan 3',
    @PostalCode = '44112',
    @Country = 'Sverige',
    @City = 'Malmö',
    @Password = 'SimonPassword456!'

EXEC Newuser 
	@RoleID = 2,
    @FirstName = 'Elin',
    @LastName = 'Dahl',
    @Email = 'elin.dahl@email.com',
    @PhoneNumber = '0766655443',
    @Address = 'Långgatan 6',
    @PostalCode = '77333',
    @Country = 'Sverige',
    @City = 'Helsingborg',
    @Password = 'ElinPassword567!'

-- Run report to see all users in the database

SELECT* 
FROM Users

-- Inserts data in the table LoginAttempts

INSERT INTO LoginAttempts (UserID, IPAdress, AttemptTime, Success, Email, Statuscode, StatusMessage ) VALUES
(1, '192.168.100.1', '2025-02-01 08:15:00', 1, 'erik.andersson@email.com', 1, 'Login successful'),
(1, '192.168.100.1', '2025-02-01 08:15:00', 1, 'erik.andersson@email.com', 1, 'Login successful'),
(1, '192.168.100.1', '2025-02-01 08:15:00', 1, 'erik.andersson@email.com', 1, 'Login successful'),
(1, '192.168.100.1', '2025-02-01 08:15:00', 0, 'erik.andersson@email.com', 0, 'Login failed'),
(1, '192.168.100.2', '2025-02-02 14:30:00', 0, 'erik.andersson@email.com', 0, 'Login failed'),
(2, '192.168.100.3', '2025-02-01 09:00:00', 1, 'anna.johansson@email.com', 1, 'Login successful'),
(2, '192.168.100.4', '2025-02-02 10:45:00', 1, 'anna.johansson@email.com', 1, 'Login successful'),
(3, '192.168.100.5', '2025-02-02 11:15:00', 0, 'lars.karlsson@email.com', 0, 'Login failed'),
(3, '192.168.100.6', '2025-02-03 16:00:00', 1, 'lars.karlsson@email.com', 1, 'Login successful'),
(4, '192.168.100.7', '2025-02-04 17:30:00', 1, 'maria.nilsson@email.com', 1, 'Login successful'),
(5, '192.168.100.8', '2025-02-05 06:00:00', 1, 'olof.berg@email.com', 1, 'Login successful'),
(5, '192.168.100.9', '2025-02-05 07:15:00', 0, 'olof.berg@email.com', 0, 'Login failed'),
(6, '192.168.100.10', '2025-02-06 12:25:00', 1, 'karin.eriksson@email.com', 1, 'Login successful'),
(6, '192.168.100.11', '2025-02-06 18:40:00', 1, 'karin.eriksson@email.com', 1, 'Login successful'),
(7, '192.168.100.12', '2025-02-07 08:50:00', 0, 'johan.lindberg@email.com', 0, 'Login failed'),
(8, '192.168.100.13', '2025-02-07 09:30:00', 1, 'emma.persson@email.com', 1, 'Login successful'),
(9, '192.168.100.14', '2025-02-08 11:10:00', 1, 'henrik.svensson@email.com', 1, 'Login successful'),
(9, '192.168.100.15', '2025-02-09 15:45:00', 0, 'henrik.svensson@email.com', 0, 'Login failed'),
(10, '192.168.100.16', '2025-02-09 18:00:00', 1, 'linda.gustafsson@email.com', 1, 'Login successful'),
(11, '192.168.100.17', '2025-02-10 08:00:00', 0, 'andreas.blom@email.com', 0, 'Login failed'),
(12, '192.168.100.18', '2025-02-11 10:20:00', 1, 'sofia.hedlund@email.com', 1, 'Login successful'),
(13, '192.168.100.19', '2025-02-11 16:50:00', 1, 'niklas.aberg@email.com', 1, 'Login successful'),
(14, '192.168.100.20', '2025-02-12 17:10:00', 0, 'evelina.holm@email.com', 0, 'Login failed'),
(15, '192.168.100.21', '2025-02-13 07:25:00', 1, 'marcus.engstrom@email.com', 1, 'Login successful'),
(16, '192.168.100.22', '2025-02-13 11:35:00', 1, 'ida.wiklund@email.com', 1, 'Login successful'),
(17, '192.168.100.23', '2025-02-14 09:45:00', 0, 'patrik.strom@email.com', 0, 'Login failed'),
(18, '192.168.100.24', '2025-02-14 13:15:00', 1, 'camilla.nord@email.com', 1, 'Login successful'),
(19, '192.168.100.25', '2025-02-15 14:00:00', 1, 'simon.lindqvist@email.com', 1, 'Login successful'),
(20, '192.168.100.26', '2025-02-15 16:45:00', 0, 'elin.dahl@email.com', 0, 'Login failed'),
(1, '192.168.100.27', '2025-02-16 09:10:00', 1, 'erik.andersson@email.com', 1, 'Login successful'),
(2, '192.168.100.28', '2025-02-16 11:00:00', 1, 'anna.johansson@email.com', 1, 'Login successful'),
(3, '192.168.100.29', '2025-02-17 08:40:00', 0, 'lars.karlsson@email.com', 0, 'Login failed'),
(4, '192.168.100.30', '2025-02-17 09:50:00', 1, 'maria.nilsson@email.com', 1, 'Login successful'),
(5, '192.168.100.31', '2025-02-18 10:20:00', 1, 'olof.berg@email.com', 1, 'Login successful'),
(6, '192.168.100.32', '2025-02-18 12:30:00', 1, 'karin.eriksson@email.com', 1, 'Login successful'),
(7, '192.168.100.33', '2025-02-19 13:25:00', 1, 'johan.lindberg@email.com', 1, 'Login successful'),
(8, '192.168.100.34', '2025-02-19 14:50:00', 0, 'emma.persson@email.com', 0, 'Login failed'),
(9, '192.168.100.35', '2025-02-20 09:05:00', 1, 'henrik.svensson@email.com', 1, 'Login successful'),
(10, '192.168.100.36', '2025-02-20 11:00:00', 1, 'linda.gustafsson@email.com', 1, 'Login successful'),
(11, '192.168.100.37', DATEADD(MINUTE, -2, GETDATE()), 0, 'andreas.blom@email.com', 0, 'Login failed'),
(11, '192.168.100.37', DATEADD(MINUTE, -5, GETDATE()), 0, 'andreas.blom@email.com', 0, 'Login failed'),
(11, '192.168.100.37', DATEADD(MINUTE, -7, GETDATE()), 0, 'andreas.blom@email.com', 0, 'Login failed'),
(11, '192.168.100.37', DATEADD(MINUTE, -10, GETDATE()), 0, 'andreas.blom@email.com', 0, 'Login failed'),
(12, '192.168.100.38', '2025-02-21 10:15:00', 1, 'sofia.hedlund@email.com', 1, 'Login successful'),
(13, '192.168.100.39', '2025-02-22 13:40:00', 1, 'niklas.aberg@email.com', 1, 'Login successful'),
(14, '192.168.100.40', '2025-02-22 15:30:00', 1, 'evelina.holm@email.com', 1, 'Login successful'),
(15, '192.168.100.41', '2025-02-23 08:00:00', 0, 'marcus.engstrom@email.com', 0, 'Login failed'),
(16, '192.168.100.42', '2025-02-23 11:30:00', 0, 'ida.wiklund@email.com', 0, 'Login failed'),
(17, '192.168.100.43', '2025-02-24 13:20:00', 1, 'patrik.strom@email.com', 1, 'Login successful'),
(18, '192.168.100.44', '2025-02-24 15:50:00', 0, 'camilla.nord@email.com', 0, 'Login failed'),
(19, '192.168.100.45', '2025-02-25 09:40:00', 1, 'simon.lindqvist@email.com', 1, 'Login successful'),
(20, '192.168.100.46', '2025-02-25 13:15:00', 1, 'elin.dahl@email.com', 1, 'Login successful')
GO


-- The code below shows a view "Userloginoverview" with all users' email address, first and last name, date/time of last successful login and date/time of last failed login. 

CREATE OR ALTER VIEW Userloginoverview AS WITH 

LastSuccessful AS (
SELECT UserID, MAX(AttemptTime) AS LastSuccess
FROM LoginAttempts
WHERE Success = 1
GROUP BY UserID
),

LastFailed AS (
SELECT UserID, MAX(AttemptTime) AS LastFailure
FROM LoginAttempts
WHERE Success = 0
GROUP BY UserID
)

SELECT u.Email AS [E-mail address], 
	U.FirstName AS [First Name], 
    U.LastName AS [Last Name], 
    LS.LastSuccess AS [Last successful login], 
    LF.LastFailure AS [Last unsuccessful login]
FROM Users U
LEFT JOIN LastSuccessful lS ON U.UserID = LS.UserID
LEFT JOIN LastFailed LF ON U.UserID = LF.UserID
GO

-- Run report 

SELECT*
FROM Userloginoverview
GO


-- The code below shows a view "LoginTryReport" with the number of successful and unsuccessful login attempts per IP address, the number of attempts (total, successful and unsuccessful) and the average of the successful attempts. All columns are sorted cumulatively by date. 

CREATE OR ALTER VIEW LoginTryReport AS
SELECT IPAdress AS [IP address],
    AttemptTime AS [Attempt Time],
    COUNT(*) OVER (PARTITION BY IPAdress ORDER BY AttemptTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Total number of attempts],
    SUM(CASE WHEN Success = 1 THEN 1 ELSE 0 END) OVER (PARTITION BY IPAdress ORDER BY AttemptTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Successful attempts],
    SUM(CASE WHEN Success = 0 THEN 1 ELSE 0 END) OVER (PARTITION BY IPAdress ORDER BY AttemptTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Failed attempts],
    AVG(CASE WHEN Success = 1 THEN 1.0 ELSE 0 END) OVER (PARTITION BY IPAdress ORDER BY AttemptTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Average of successful attempts],
	CAST(ROUND(AVG(CASE WHEN Success = 1 THEN 1.0 ELSE 0 END) 
        OVER (PARTITION BY IPAdress ORDER BY AttemptTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100, 2) AS DECIMAL(5,2)) AS [Successful attempts in %]
FROM LoginAttempts
GO

-- Run report

SELECT* 
FROM LoginTryReport
ORDER BY [Attempt Time]
GO


-- The code below shows a function "FailedLoginCheck" as if you have failed to log in three times in the last 15 minutes, you will not be able to get in regardless of whether you type the correct password or not.

CREATE OR ALTER FUNCTION dbo.FailedLoginCheck (@UserID INT)

	RETURNS TINYINT
AS
BEGIN

	DECLARE @FailedAttempts INT = 0;

	SELECT @FailedAttempts = COUNT(*)
	FROM LoginAttempts
	WHERE UserID = @UserID AND Success = 0 AND AttemptTime > DATEADD(MINUTE, -15, GETDATE())

	RETURN CASE WHEN @FailedAttempts >= 3 THEN 1 ELSE 0 END

END
GO

-- Run the report below for user ID 11 which is Andreas Blom. 
-- If the result shows 0 then the user is not locked out and if it shows 1 then it means three failed login attempts in 15 minutes and the user is locked out.

SELECT dbo.FailedLoginCheck (11) AS [Is locked out]
GO

-- The code below shows a stored procedure for trylogin 

CREATE OR ALTER PROCEDURE dbo.TryLogin
    @Email NVARCHAR(50),
    @Password NVARCHAR(100),
    @IPAddress NVARCHAR(50)
AS
BEGIN

CREATE TABLE #TempLogin (
    AttemptID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    Email NVARCHAR(50),
    IPAddress NVARCHAR(50),
    AttemptTime DATETIME DEFAULT GETDATE(),
    IsSuccessful BIT,
    StatusCode INT,
    StatusMessage NVARCHAR(255)
)
    DECLARE @UserID INT;
    DECLARE @PasswordSalt NVARCHAR(100)
    DECLARE @PasswordHash NVARCHAR(100)
    DECLARE @ComputedHash NVARCHAR(100)
    DECLARE @IsLocked BIT
    DECLARE @FailedCheck TINYINT
    DECLARE @StatusCode INT
    DECLARE @StatusMessage NVARCHAR(255)

    SELECT @UserID = UserID,
           @PasswordHash = PasswordHash,
           @PasswordSalt = PasswordSalt,
           @IsLocked = IsLocked
    FROM Users
    WHERE Email = @Email


IF @UserID IS NULL
BEGIN
    SET @StatusCode = -1
    SET @StatusMessage = 'User does not exist'

    INSERT INTO #TempLogin (UserID, Email, IPAddress, AttemptTime, IsSuccessful, StatusCode, StatusMessage)
    VALUES (NULL, @Email, @IPAddress, GETDATE(), 0, @StatusCode, @StatusMessage)

    INSERT INTO LoginAttempts (UserID, IPAdress, AttemptTime, Success)
    VALUES (NULL, @IPAddress, GETDATE(), 0)

    SELECT*
	FROM #TempLogin
    RETURN @StatusCode
END



IF @IsLocked = 1
BEGIN
    SET @StatusCode = -2
    SET @StatusMessage = 'User is locked'

    INSERT INTO #TempLogin (UserID, Email, IPAddress, AttemptTime, IsSuccessful, StatusCode, StatusMessage)
    VALUES (@UserID, @Email, @IPAddress, GETDATE(), 0, @StatusCode, @StatusMessage)

    INSERT INTO LoginAttempts (UserID, IPAdress, AttemptTime, Success)
    VALUES (@UserID, @IPAddress, GETDATE(), 0)

    SELECT* 
	FROM #TempLogin
    RETURN @StatusCode
END


	SET @FailedCheck = dbo.FailedLoginCheck(@UserID)


IF @FailedCheck = 1
BEGIN
    UPDATE Users
    SET IsLocked = 1
    WHERE UserID = @UserID

    SET @StatusCode = -3
    SET @StatusMessage = 'User is locked, to too many failed attempts'

    INSERT INTO #TempLogin (UserID, Email, IPAddress, AttemptTime, IsSuccessful, StatusCode, StatusMessage)
    VALUES (@UserID, @Email, @IPAddress, GETDATE(), 0, @StatusCode, @StatusMessage)

    INSERT INTO LoginAttempts (UserID, IPAdress, AttemptTime, Success)
    VALUES (@UserID, @IPAddress, GETDATE(), 0)

    SELECT*
	FROM #TempLogin
    RETURN @StatusCode
END


    SET @ComputedHash = CONVERT(NVARCHAR(100), HASHBYTES('SHA2_256', @Password + @PasswordSalt), 1)


IF @ComputedHash = @PasswordHash
BEGIN
    SET @StatusCode = 1
    SET @StatusMessage = 'Login successful'

    INSERT INTO #TempLogin (UserID, Email, IPAddress, AttemptTime, IsSuccessful, StatusCode, StatusMessage)
    VALUES (@UserID, @Email, @IPAddress, GETDATE(), 1, @StatusCode, @StatusMessage)

    INSERT INTO LoginAttempts (UserID, IPAdress, AttemptTime, Success)
    VALUES (@UserID, @IPAddress, GETDATE(), 1)

    SELECT * FROM #TempLogin
    RETURN @StatusCode
END


ELSE
BEGIN
    SET @StatusCode = 0
    SET @StatusMessage = 'Login failed'

    INSERT INTO #TempLogin (UserID, Email, IPAddress, AttemptTime, IsSuccessful, StatusCode, StatusMessage)
    VALUES (@UserID, @Email, @IPAddress, GETDATE(), 0, @StatusCode, @StatusMessage)

    INSERT INTO LoginAttempts (UserID, IPAdress, AttemptTime, Success)
    VALUES (@UserID, @IPAddress, GETDATE(), 0)

    SELECT * FROM #TempLogin
    RETURN @StatusCode
END

END
GO

-- Run reports 

-- For the error message and error code "User does not exist" it is an incorrect email.

DECLARE @TryLoginR INT
 
EXEC @TryLoginR = dbo.TryLogin
	@Email = 'andreass.blom@email.com',
	@Password = 'AndreasPassword345!', 
	@IPAddress =  '192.168.100.37'
 
SELECT @TryLoginR AS LoginStatus
GO

-- For the error message and error code "Login failed", execute the code one time to get the correct error message and code.
-- For the error message and error code "User is locked due to too many failed attempts", execute the code three times to get the correct error message and code.

DECLARE @TryLoginR INT

EXEC @TryLoginR = dbo.TryLogin
	@Email = 'erik.andersson@email.com',
	@Password = 'ErikPasssword123!!', 
	@IPAddress =  '192.168.100.1'

 
SELECT @TryLoginR AS LoginStatus
GO

-- For the error message and error code "Login successful", do not change anything. 

 DECLARE @TryLoginR INT
 
EXEC @TryLoginR = dbo.TryLogin
	@Email = 'elin.dahl@email.com',
	@Password = 'ElinPassword567!', 
	@IPAddress =  '192.168.100.46'
 
SELECT @TryLoginR AS LoginStatus
GO

-- For the error message and error code "Login failed", so is it the wrong password.

 DECLARE @TryLoginR INT
 
EXEC @TryLoginR = dbo.TryLogin
	@Email = 'simon.lindqvist@email.com',
	@Password = 'SimonPasssword456!', 
	@IPAddress =  '192.168.100.45';
 
SELECT @TryLoginR AS LoginStatus
GO

-- The code below shows a stored procedure for forgotpassword 

CREATE OR ALTER PROCEDURE dbo.ForgotPassword
    @Email NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON

    CREATE TABLE #TempPasswordReset (
    ResetID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    Email NVARCHAR(50),
    ResetToken UNIQUEIDENTIFIER,
    CreatedAt DATETIME DEFAULT GETDATE(),
    ExpiryAt DATETIME,
    StatusCode INT,
    StatusMessage NVARCHAR(255)
)

    DECLARE @UserID INT
    DECLARE @ResetToken UNIQUEIDENTIFIER
    DECLARE @StatusCode INT
    DECLARE @StatusMessage NVARCHAR(255)

    SELECT @UserID = UserID 
	FROM Users 
	WHERE Email = @Email

IF @UserID IS NULL
BEGIN
    SET @StatusCode = -1
    SET @StatusMessage = 'User does not exist'

    INSERT INTO #TempPasswordReset (UserID, Email, ResetToken, CreatedAt, ExpiryAt, StatusCode, StatusMessage)
    VALUES (NULL, @Email, NULL, GETDATE(), NULL, @StatusCode, @StatusMessage)

    SELECT*
	FROM #TempPasswordReset
    RETURN @StatusCode
END

    SET @ResetToken = NEWID()

    INSERT INTO PasswordReset (UserID, ResetToken, StatusMessage, StatusCode)
    VALUES (@UserID, @ResetToken, 'Reset token created', 1)

    SET @StatusCode = 1
    SET @StatusMessage = 'Password reset created successfully'

    INSERT INTO #TempPasswordReset (UserID, Email, ResetToken, CreatedAt, ExpiryAt, StatusCode, StatusMessage)
    VALUES (@UserID, @Email, @ResetToken, GETDATE(), DATEADD(HOUR, 24, GETDATE()), @StatusCode, @StatusMessage)

    SELECT*
	FROM #TempPasswordReset
    RETURN @StatusCode
END
GO

-- Run reports

-- For the error message and error code "User does not exist" it is an incorrect email, which does not exist in the database. 

DECLARE @ForgotPasswordR INT

EXEC @ForgotPasswordR = dbo.ForgotPassword
    @Email = 'andreass.blom@email.com'

SELECT @ForgotPasswordR AS StatusCode
GO

-- For the error message and error code "Password reset created successfully" it is a correct email-address which is in the database.

DECLARE @ForgotPasswordR INT

EXEC @ForgotPasswordR = dbo.ForgotPassword
    @Email = 'andreas.blom@email.com'

SELECT @ForgotPasswordR AS StatusCode
GO


-- The code below shows a stored procedure for setforgottenpassword

CREATE OR ALTER PROCEDURE dbo.SetForgottenPassword
    @Email NVARCHAR(50),
    @Password NVARCHAR(100),
    @Token UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @UserID INT
    DECLARE @StoredToken UNIQUEIDENTIFIER
    DECLARE @ExpiryAt DATETIME
    DECLARE @PasswordSalt NVARCHAR(100)
    DECLARE @PasswordHash NVARCHAR(100)
    DECLARE @StatusCode INT
    DECLARE @StatusMessage NVARCHAR(255)
    DECLARE @CurrentPasswordHash NVARCHAR(100)
    DECLARE @CurrentSalt NVARCHAR(100)
    DECLARE @IsUsed BIT

    SELECT @UserID = UserID 
    FROM Users 
    WHERE Email = @Email


IF @UserID IS NULL
BEGIN
    SET @StatusCode = -1
    SET @StatusMessage = 'User does not exist'
    SELECT @StatusCode AS StatusCode, @StatusMessage AS StatusMessage
    RETURN
END

    SELECT @StoredToken = ResetToken, @ExpiryAt = ExpiryAt, @IsUsed = IsUsed
    FROM PasswordReset 
    WHERE UserID = @UserID AND ResetToken = @Token


 IF @StoredToken IS NULL
 BEGIN
    SET @StatusCode = -2
    SET @StatusMessage = 'Invalid token'
    SELECT @StatusCode AS StatusCode, @StatusMessage AS StatusMessage
    RETURN
END

IF @IsUsed = 1
BEGIN
    SET @StatusCode = -5
    SET @StatusMessage = 'Token has already been used'
    SELECT @StatusCode AS StatusCode, @StatusMessage AS StatusMessage
    RETURN
END

IF @ExpiryAt < GETDATE()
BEGIN
    SET @StatusCode = -3
    SET @StatusMessage = 'Token has expired'
    SELECT @StatusCode AS StatusCode, @StatusMessage AS StatusMessage, @ExpiryAt AS ExpiryAt
    RETURN
END

    SELECT @CurrentPasswordHash = PasswordHash, @CurrentSalt = PasswordSalt
    FROM Users 
    WHERE UserID = @UserID

    SET @PasswordHash = CONVERT(NVARCHAR(100), HASHBYTES('SHA2_256', @Password + @CurrentSalt), 1)


IF @PasswordHash = @CurrentPasswordHash
BEGIN
    SET @StatusCode = -4;
    SET @StatusMessage = 'New password cannot be the same as the old password'
    SELECT @StatusCode AS StatusCode, @StatusMessage AS StatusMessage
    RETURN
END

    SET @PasswordSalt = CONVERT(NVARCHAR(100), NEWID());
    SET @PasswordHash = CONVERT(NVARCHAR(100), HASHBYTES('SHA2_256', @Password + @PasswordSalt), 1)

    UPDATE Users
    SET PasswordHash = @PasswordHash, PasswordSalt = @PasswordSalt
    WHERE UserID = @UserID

    UPDATE PasswordReset
    SET IsUsed = 1
    WHERE UserID = @UserID AND ResetToken = @Token;

    SET @StatusCode = 1
    SET @StatusMessage = 'Password updated successfully'

    SELECT @StatusCode AS StatusCode, @StatusMessage AS StatusMessage
END
GO

-- Run reports

-- For the error message and error code "User does not exist" it is an incorrect email, which does not exist in the database. 

DECLARE @SetForgottenPasswordR INT

EXEC dbo.SetForgottenPassword
    @Email = 'simonn.lindqvist@email.com',
    @Password = 'SimonPassword456!',
    @Token = '89D3E2B3-DC34-4BD5-91E4-5E97867A0E0C'
GO

-- For the error message and error code "Invalid token" it is an incorrect token

DECLARE @SetForgottenPasswordR INT

EXEC dbo.SetForgottenPassword
    @Email = 'simon.lindqvist@email.com',
    @Password = 'SimonPassword456!',
    @Token = '89D3E2B3-DC34-4BD5-91E4-5E97867A0E0CCCCC'
GO

-- For the error message and error code "Token has already been used"
-- Start by execute @SetForgottenPasswordR and copy the code under ‘ResetToken’.
-- Paste the code in @SetForgottenPasswordR where it says ‘Token’.
-- Execute @SetForgottenPasswordR twice for the error message and error code "Token has already been used".

DECLARE @ForgotPasswordR INT

EXEC @ForgotPasswordR = dbo.ForgotPassword
    @Email = 'andreas.blom@email.com'

SELECT @ForgotPasswordR AS StatusCode
GO

----------

DECLARE @SetForgottenPasswordR INT

EXEC dbo.SetForgottenPassword
    @Email = 'andreas.blom@email.com',
    @Password = 'AndreasPassword345!',
    @Token = '101F73E2-9A04-4170-A70E-BCCEFC88209E';


-- If the code is more than 24 hours old, the error message shows "Token has expired" and the error code "-3".
-- The code below shows when the token was created and expires and that it is valid for 24 hours. 

DECLARE @ForgotPasswordR INT

EXEC @ForgotPasswordR = dbo.ForgotPassword
    @Email = 'andreas.blom@email.com'

SELECT @ForgotPasswordR AS StatusCode
GO

-- For the error message and error code "New password cannot be the same as the old password"
-- Start by execute the code @ForgotPasswordR and copy the code for the token
-- Paste the code into @SetForgottenPasswordR for token and execute
-- Then we can see the error message and error code because we used the same password

DECLARE @SetForgottenPasswordR INT

EXEC dbo.SetForgottenPassword
    @Email = 'andreas.blom@email.com',
    @Password = 'AndreasPassword345!',
    @Token = '8BD9FF33-EB85-46F8-BAFB-C85E03703776'

------

DECLARE @ForgotPasswordR INT

EXEC @ForgotPasswordR = dbo.ForgotPassword
    @Email = 'andreas.blom@email.com'

SELECT @ForgotPasswordR AS StatusCode
GO

-- For the error message and error code "Password updated successfullyd"
-- Start by execute the code @ForgotPasswordR and copy the code for the token
-- Note that I have changed the password 
-- Paste the code into @SetForgottenPasswordR for token and execute for a successful password update.

DECLARE @SetForgottenPasswordR INT

EXEC dbo.SetForgottenPassword
    @Email = 'andreas.blom@email.com',
    @Password = 'hejpådig123!?',
    @Token = 'CAA663DE-ECB8-4395-9FBD-683E3154B0D7'

------

DECLARE @ForgotPasswordR INT

EXEC @ForgotPasswordR = dbo.ForgotPassword
    @Email = 'andreas.blom@email.com'

SELECT @ForgotPasswordR AS StatusCode
GO

