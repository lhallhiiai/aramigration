<!--- Pull Grace's megaquery, to be replaced when approval is implemented --->

<cfquery name="agreement" datasource="#application.ods#">
	SELECT agreement_id
	FROM agreements
	WHERE jamisNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARAdetails.jamisNo#">
</cfquery>

<cfquery name="contractDetails" datasource="#application.ods#">
SELECT 

      pvt.[agreement_id]
      ,[Program Manager] as PM_num
      , pm.full_name as PM_name
      ,[Contract Administrator] as CA_num
        , ca.full_name as CA_name
      ,[Sector Manager] as SM_num
        ,sm.full_name as SM_name
      ,[Group Manager] as GM_num
        ,gm.full_name as GM_name
      ,[Operation Manager] as OM_num
        ,om.full_name as OM_name
      ,[Division Manager] as DM_num
        ,dm.full_name as DM_name
        ,cor.name as [COR Office]
FROM
(SELECT  

        A.[agreement_id]

      ,'0000'+PC.[employee_id] AS [employee_id]

      ,PC.[Role]

  FROM [cae_ods].[dbo].[agreements] AS A

  LEFT OUTER JOIN [cae_ods].[dbo].[partyContacts] AS PC

  ON A.[agreement_id] = PC.[agreement_id]

  WHERE A.[agreement_id] = #agreement.agreement_id#  

UNION

SELECT 

        [agreement_id]

      ,[employee_id]

      ,[role]

FROM 

(SELECT  

        A.[agreement_id]

      ,SEC.[org_mngr] AS [Sector Manager]

      ,GRP.[org_mngr] AS [Group Manager]

      ,OPRTN.[org_mngr] AS [Operation Manager]

  FROM [cae_ods].[dbo].[agreements] AS A

  LEFT OUTER JOIN [cae_ods].[dbo].[partyContacts] AS PC

  ON A.[agreement_id] = PC.[agreement_id]

  LEFT OUTER JOIN [cae_ods].[dbo].[empl] AS E

  ON ('0000'+PC.[employee_id]) = E.[empl_nmbr]

  LEFT OUTER JOIN [cae_ods].[dbo].[Org] AS O

  ON E.[cost_cntr] = O.org

  LEFT OUTER JOIN [cae_ods].[dbo].[Org] AS SEC

  ON O.[sctr] = SEC.[org]

  LEFT OUTER JOIN [cae_ods].[dbo].[Org] AS GRP

  ON O.[grp] = GRP.[org]

  LEFT OUTER JOIN [cae_ods].[dbo].[Org] AS OPRTN

  ON O.[OPRTN] = OPRTN.[org]

  WHERE A.[agreement_id] = #agreement.agreement_id# 

  and PC.[Role] = 'Program Manager') as P

UNPIVOT

   ([employee_id] FOR [role] IN 

      ([Sector Manager], [Group Manager], [Operation Manager])

)AS unpvt)

AS pvt_qry

PIVOT (MAX([employee_id])

FOR [role] IN 

([Program Manager] 

        ,[Contract Administrator]

        ,[Sector Manager]

        ,[Group Manager]

        ,[Operation Manager]

        ,[Division Manager]))

AS pvt

LEFT OUTER JOIN [cae_ods].[dbo].[empl] AS PM
 on pvt.[Program Manager]=pm.[empl_nmbr]
LEFT OUTER JOIN [cae_ods].[dbo].[empl] AS CA
 on pvt.[Contract Administrator]=ca.[empl_nmbr]
LEFT OUTER JOIN [cae_ods].[dbo].[empl] AS SM
 on pvt.[Sector Manager]=sm.[empl_nmbr] 
LEFT OUTER JOIN [cae_ods].[dbo].[empl] AS GM
 on pvt.[Group Manager]=gm.[empl_nmbr]
LEFT OUTER JOIN [cae_ods].[dbo].[empl] AS OM
 on pvt.[Operation Manager]=om.[empl_nmbr]
LEFT OUTER JOIN [cae_ods].[dbo].[empl] AS DM
 on pvt.[Division Manager]=dm.[empl_nmbr]
LEFT OUTER JOIN 
(SELECT EPR.[agreement_id]
      ,[name]
  FROM [cae_ods].[dbo].[externalpartyroles] AS EPR
  LEFT OUTER JOIN [cae_ods].[dbo].[party] AS P
  ON [externalparty_id] = [party_id] 
  where [agreement_id] = #agreement.agreement_id# 
  and [role] = 'COR Office') COR on pvt.agreement_id=COR.agreement_id

</cfquery>