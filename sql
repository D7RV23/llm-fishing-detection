-- Table 1: EmailData

CREATE TABLE EmailData (
    EmailID INTEGER PRIMARY KEY,
    EmailText TEXT NOT NULL,
    EmailType TEXT NOT NULL  'Safe Email' or 'Phishing Email'
);


-- Table 2: DetectionResults
-- Stores the outcomes from the human participants, ML model, and LLM for comparison.
-- This is designed to track True Positives, False Positives, etc. for the project's evaluation.

CREATE TABLE DetectionResults (
    ResultID INTEGER PRIMARY KEY AUTOINCREMENT,
    EmailID INTEGER NOT NULL,
    DetectionSource TEXT NOT NULL, -- 'Human', 'SVM Model', 'LLM'
    PredictedType TEXT NOT NULL,   --  'Phishing Email', 'Safe Email'
    DemographicGroup TEXT,         -- For analysis of demographic performance
    FOREIGN KEY (EmailID) REFERENCES EmailData(EmailID)
);


— most common type of email
SELECT
    EmailType,
    COUNT(*) AS TotalCount,
  
    ROUND(CAST(COUNT(*) AS REAL) * 100 / (SELECT COUNT(*) FROM EmailData), 2) AS Percentage
FROM
    EmailData
GROUP BY
    EmailType
ORDER BY
    TotalCount DESC;


-- Query to compare False Positive Rate across demographics for human participants
SELECT
    DemographicGroup,
    COUNT(*) AS TotalGuesses,
    SUM(CASE WHEN PredictedType = 'Phishing Email' AND ed.EmailType = 'Safe Email' THEN 1 ELSE 0 END) AS Total_False_Positives,
    ROUND(SUM(CASE WHEN PredictedType = 'Phishing Email' AND ed.EmailType = 'Safe Email' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS False_Positive_Rate
FROM
    DetectionResults dr
JOIN
    EmailData ed ON dr.EmailID = ed.EmailID
WHERE
    dr.DetectionSource = 'Human' -- Only look at human results
GROUP BY
    DemographicGroup
ORDER BY
    False_Positive_Rate DESC;


-- Query to compare False Positive Rate across demographics 
SELECT
    DemographicGroup,
    COUNT(*) AS TotalGuesses,
    SUM(CASE WHEN PredictedType = 'Phishing Email' AND ed.EmailType = 'Safe Email' THEN 1 ELSE 0 END) AS Total_False_Positives,
    ROUND(SUM(CASE WHEN PredictedType = 'Phishing Email' AND ed.EmailType = 'Safe Email' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS False_Positive_Rate
FROM
    DetectionResults dr
JOIN
    EmailData ed ON dr.EmailID = ed.EmailID
WHERE
    dr.DetectionSource = 'Human' 
GROUP BY
    DemographicGroup
ORDER BY
    False_Positive_Rate DESC;

