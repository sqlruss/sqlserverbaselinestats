CREATE PROCEDURE [Queues].[GetCounterValuesForGrafana]
@ServerName NVARCHAR(50), 
@CounterGroup VARCHAR(200), 
@CounterName VARCHAR(200), 
@StartTime DATETIME2(0), 
@EndTime DATETIME2(0)
AS
BEGIN

    /*REGION - if counter is specific to named instance, update CounterGroup name*/
        DECLARE @NamedInstanceMetricPrefix VARCHAR(50) = 'mssql$' + STUFF(@ServerName,1,CHARINDEX('\',@ServerName),'')
        DECLARE @NamedInstanceCounterGroupPrefix VARCHAR(200) = STUFF(@CounterGroup,1,9,'')

        IF @CounterGroup LIKE 'sqlserver:%' AND @ServerName LIKE '%\%'
        BEGIN
            SET @CounterGroup = '\'+ @NamedInstanceMetricPrefix + @NamedInstanceCounterGroupPrefix
        END
        ELSE
        BEGIN
            SET @CounterGroup = '\'+ @CounterGroup
        END
    /*END REGION - if counter is specific to named instance, update CounterGroup name*/

    IF @CounterName = 'Total Server Memory (KB)'
        BEGIN
            SELECT  [time], CounterGroupAndName, CounterValue 
            FROM    Queues.CounterValuesForGrafana
            WHERE   1 = 1 
                    AND ServerName = @ServerName
                    AND CounterGroup = @CounterGroup
                    AND (CounterName = @CounterName OR CounterName = 'Target Server Memory (KB)')
                    AND [time] >= @StartTime
                    AND [time] <= @EndTime
            ORDER BY [time] ASC
        END
    ELSE
        IF @CounterGroup = '\physicaldisk'
            BEGIN
                SELECT  [time], CounterGroupAndName, CounterValue 
                FROM    Queues.CounterValuesForGrafana
                WHERE   1 = 1 
                        AND ServerName = @ServerName
                        AND CounterGroup LIKE '\physicaldisk%'
                        AND CounterGroup NOT LIKE '%c:%'
                        AND CounterGroup NOT LIKE '%_total%'
                        AND CounterName = @CounterName
                        AND [time] >= @StartTime
                        AND [time] <= @EndTime
                ORDER BY [time] ASC
            END
        ELSE
            IF @CounterGroup = '\network interface'
                BEGIN
                    SELECT  [time], CounterGroupAndName, CounterValue 
                    FROM    Queues.CounterValuesForGrafana
                    WHERE   1 = 1 
                            AND ServerName = @ServerName
                            AND CounterGroup LIKE '\network interface%'
                            AND CounterName = @CounterName
                            AND [time] >= @StartTime
                            AND [time] <= @EndTime
                    ORDER BY [time] ASC
                END
            ELSE
                IF @CounterGroup = '\vm memory' AND @CounterName = 'memory mapped in mb'
                    BEGIN
                        SELECT  [time], CounterGroupAndName, CounterValue 
                        FROM    Queues.CounterValuesForGrafana
                        WHERE   1 = 1 
                                AND ServerName = @ServerName
                                AND CounterGroup = @CounterGroup
                                AND CounterName IN ('memory active in mb', 'memory ballooned in mb', 'memory mapped in mb', 'memory reservation in mb', 'memory swapped in mb')
                                AND [time] >= @StartTime
                                AND [time] <= @EndTime
                        ORDER BY [time] ASC
                    END
                ELSE
                    IF @CounterGroup = '\vm memory' AND @CounterName = 'memory shares'
                        BEGIN
                            SELECT  [time], CounterGroupAndName, CounterValue 
                            FROM    Queues.CounterValuesForGrafana
                            WHERE   1 = 1 
                                    AND ServerName = @ServerName
                                    AND CounterGroup = @CounterGroup
                                    AND CounterName IN ('memory shares')
                                    AND [time] >= @StartTime
                                    AND [time] <= @EndTime
                            ORDER BY [time] ASC
                        END
                    ELSE
                        IF @CounterGroup LIKE '%memory manager%'
                            BEGIN
                                SELECT  [time], CounterGroupAndName, CounterValue 
                                FROM    Queues.CounterValuesForGrafana
                                WHERE   1 = 1 
                                        AND ServerName = @ServerName
                                        AND CounterGroup = @CounterGroup
                                        AND CounterName LIKE 'memory grants%'
                                        AND [time] >= @StartTime
                                        AND [time] <= @EndTime
                                ORDER BY [time] ASC
                            END
                        ELSE
                            IF @CounterGroup LIKE '%wait statistics(waits in progress)' AND @CounterName = 'lock waits'
                                BEGIN
                                    SELECT  [time], CounterGroupAndName, CounterValue 
                                    FROM    Queues.CounterValuesForGrafana
                                    WHERE   1 = 1 
                                            AND ServerName = @ServerName
                                            AND CounterGroup = @CounterGroup
                                            --AND CounterName = @CounterName
                                            AND [time] >= @StartTime
                                            AND [time] <= @EndTime
                                    ORDER BY [time] ASC
                                END
                            ELSE
                                IF @CounterGroup LIKE '%wait statistics(waits in progress)' AND @CounterName = ''
                                    BEGIN
                                        SELECT  [time], SUM(CounterValue) AS 'CounterValue'
                                        FROM    Queues.CounterValuesForGrafana
                                        WHERE   1 = 1 
                                                AND ServerName = @ServerName
                                                AND CounterGroup = @CounterGroup
                                                --AND CounterName = @CounterName
                                                AND [time] >= @StartTime
                                                AND [time] <= @EndTime
                                        GROUP BY [time]
                                        ORDER BY [time] ASC
                                    END
                                ELSE
                                    BEGIN
                                        SELECT  [time], CounterGroupAndName, CounterValue 
                                        FROM    Queues.CounterValuesForGrafana
                                        WHERE   1 = 1 
                                                AND ServerName = @ServerName
                                                AND CounterGroup = @CounterGroup
                                                AND CounterName = @CounterName
                                                AND [time] >= @StartTime
                                                AND [time] <= @EndTime
                                        ORDER BY [time] ASC
                                    END  
END
GO
