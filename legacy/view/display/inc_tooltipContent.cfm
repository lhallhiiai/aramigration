<cfset tooltip.img = "<img style='vertical-align: bottom;padding-left:5px;margin-bottom:3px;' src='images/tooltip-icon-tiny.png'><br>">
<cfset tooltip.wrng = "<img style='vertical-align: bottom;padding-left:5px;margin-bottom:3px;' src='images/smredwarning.png'><br>">


<cfset tooltip.warehouse = "<b>Warehouse data</b>" & tooltip.img & "Based on the CostPoint Contract Number data is retrieved from several different corporate databases. This data is view only.">
<!--- Jamis Number --->
<cfset tooltip.jamisNo = "<b>Project ID</b>" & tooltip.img & "The CostPoint Contract Number (e.g., 003800-000) for which the ARA is being created. ">
<!--- ARA Org --->
<cfset tooltip.araorg = "<b>ARA Org</b>" & tooltip.img & "The division bearing the financial burden of this ARA. This may be different from the division originating the contract.">
<!--- Jamis No or Early Start --->
<cfset tooltip.earlyStartJamisNo ="<b>Project ID or Early Start</b>" & tooltip.img & "The CostPoint Contract Number (e.g., 003800-000) for which the ARA is being created, or if work is starting before a contract, than an indication of an Early Start.">
<!--- Early Start --->
<cfset tooltip.earlyStart = "<b>Early Start</b>" & tooltip.img & "A contract does not exist. Work is being done prior to the completion of the contract or entry in CostPoint.">
<!--- Jamis Number Early Start--->
<cfset tooltip.jamisNoES = "<b>Costpoint Project Number</b>" & tooltip.img & "The CostPoint Contract Number (e.g., 003800-000) for which the ARA is being created. For Early Start ARAs this number does not exist yet.">
<!--- Revenue Recongnition--->
<cfset tooltip.Revenue = "<b>Revenue Recognition</b>" & tooltip.img & "Is there potential revenue associated with this ARA or is this a spend only ARA.">
<!--- OMSNo--->
<cfset tooltip.OMSNo = "<b>OMS Number</b>" & tooltip.img & "Cross reference ID to the Opportunity Management System (if applicable). Likely to only be applicable to Early Start ARAs.">


<!--- Sector --->
<cfset tooltip.sector = "<b>Sector</b>" & tooltip.img & "Pre-Reorg 2015. Old organizational structure: <br>Sector-> Group -> Ops -> Division. Group and division. Post 2015, only Group and Division may appear.">
<!--- Group --->
<cfset tooltip.group= "<b>Group</b>" & tooltip.img & "The second tier of  organizational structure: <br>Sector-> Group -> Ops -> Division. Prepopulated based on CostPoint contract <br>number.">
<!--- ContractNo --->
<cfset tooltip.ContractNo= "<b>Contract Number</b>" & tooltip.img & "This is the contract number (defined in CostPoint) of the direct prime customer. ">
<!--- ContractNo Early Start --->
<cfset tooltip.ContractNoES= "<b>Contract Number Early Start</b>" & tooltip.img & "This is the contract number (defined in Jamis) of the direct prime customer (e.g., N00024-01-D-7023). For <i>Early Start ARAs</i>, this number does not yet exist. ">
<!--- contractTitle --->
<cfset tooltip.contractTitle= "<b>Contract Title</b>" & tooltip.img & "This is the title of the contract for which the ARA is being submitted. For <i>Early Start</i> ARAs, this is the title that will be setup in CostPoint.">
<!--- Customer Name --->
<cfset tooltip.Customer= "<b>Customer</b>" & tooltip.img & "This is the name of the customer (synonymous with the COR Office in CKIS). For <i>Early Start</i> ARAs this is the name that will be setup in CostPoint.">
<!--- Program Manager --->
<cfset tooltip.programMgr= "<b>Program Manager</b>" & tooltip.img & "This is the program manager associated with the contract. The program manager initiates the ARA process">
<!--- Contract Administrator --->
<cfset tooltip.contractMgr= "<b>Contract Admin or Manager</b>" & tooltip.img & "The Contract Administrator is responsible for completing all of the contractual information for the ARA">
<!--- Controller --->
<cfset tooltip.Controller= "<b>Controller</b>" & tooltip.img & "The controller is responsible for completing all the financial analysis relating to the ARA.">
<!--- Group Manager --->
<cfset tooltip.groupMgr= "<b>Group Manager</b>" & tooltip.img & "The group manager is derived from the Program Manager's org structure. The group manager is part of ARA the approval process.">
<!--- Sector Manager --->
<cfset tooltip.sectorMgr= "<b>Sector Manager</b>" & tooltip.img & "The sector manager is derived from the Program Manager's org structure. Depending on the amount, the ARA may require Sector Manager approval.">
<!--- Division Manager --->
<cfset tooltip.divisionMgr= "<b>Division Manager</b>" & tooltip.img & "The sector manager is derived from the Program Manager's org structure. The ARA requires the Division Manager's approval.">
<!--- Status --->
<cfset tooltip.status= "<b>Status</b>" & tooltip.img & "The status is system determined, based on submission status. The status maybe: Draft, Submitted, Approved, Rejected, Expired, or Negated.">
<!--- Amount --->
<cfset tooltip.Amount= "<b>Amount</b>" & tooltip.img & "The total additional amount being requested. Approval levels are based of the HIII Aproval Matrix.">
<!--- RiskCategory --->
<cfset tooltip.riskCat= "<b>Risk Category</b>" & tooltip.img & "The Risk Category of the ARA. The selection of this field results in an assigned Risk Level.">
<!--- RiskLevel --->
<cfset tooltip.riskLevel= "<b>Risk Level</b>" & tooltip.img & "The level is automatically determined by the Risk category. It reflects the seriousness of the risk with a value from 1-3.">
<!--- araID --->
<cfset tooltip.araID= "<b>ARA ID</b>" & tooltip.img & "The identifier for the ARA. It is a sequential number. The combination of the ARA ID Number and the ARA Revision Number uniquely identify each version of an ARA.">
<!--- araRev --->
<cfset tooltip.araRev= "<b>ARA Revision</b>" & tooltip.img & "A system generated revision number starting with 0. If the ARA is rejected and needs to be reworked, this number will increment.">
<!--- reqStart --->
<cfset tooltip.reqStart= "<b>Required Start</b>" & tooltip.img & "This is the date that HII is required to start or continue work at-risk for the customer.">
<!--- expDate --->
<cfset tooltip.expDate= "<b>Expiration Date</b>" & tooltip.img & "See requirement 121, around page 51. I do not understand this date.">
<!--- ++++++++++++++++++++++++++++++++++++++++++ TAB SET Tool Tips ++++++++++++++++++++++++++++++ --->
<cfset tooltip.pmMinus="<b>Program Manager</b>: <br>A program manager (or like job) starts the ARA process. The basic program information has not been provided">
<cfset tooltip.pmCheck="<b>Program Manager</b>: <br>Step 1, the basic program information is complete. The ARA progresses to contracts - Step 2.">
<cfset tooltip.contractMinus="<b>Contract Information</b>: <br>Once submitted by the Program Manager, the contract manger needs to provide information about this ARA's contract - Step2.">
<cfset tooltip.contractCheck="<b>Contract Information</b>: <br>Contract information has been completed. The ARA progresses to the controller - Step 3.">
<cfset tooltip.clinsMinus="<b>CLINs Information</b>: <br>Once submitted by contracts, the controller needs to provide CLIN information & Controller Information - Step3.">
<cfset tooltip.clinsCheck="<b>CLINS Information</b>: <br>CLIN information has been completed. The ARA progresses to the Approvals Step 4.">
<cfset tooltip.controllerMinus="<b>Controller Information</b>: <br>The controller needs to provide CLIN information & Controller Information - Step3.">
<cfset tooltip.controllerCheck="<b>Controller Information</b>: <br>CLIN information has been completed. The ARA progresses to the Approvals Step 4.">
<cfset tooltip.docsCheck="<b>Documents</b>: <br>Based on the category type, certain documents are required. All required documents have been provided.">
<cfset tooltip.docsMinus="<b>Documents</b>: <br>Documents supporting this ARA category are still needed.">
<cfset tooltip.ApprovalCheck="<b>Approvals</b>: <br>All the necessary approvals have been obtained.">
<cfset tooltip.ApprovalMinus="<b>Approvals</b>: <br>This ARA has not received all the necessary approvals.">
<!--- +++++++++++++++++++++++++++++++++++++++++ CLIN TOOLTIPS ++++++++++++++++++++++++++++++++++++ --->
<!--- Clin Number --->
<cfset tooltip.clinNum= "<b>CLIN Number</b>" & tooltip.img & "The CostPoint CLIN Numbers affected by the ARA. For contracts with multiple CLINs, each CLIN is retrieved from CostPoint and displayed separately.">

<!--- +++++++++++++++++++++++++++++++++++++++++ Errors and Warnings  ++++++++++++++++++++++++++++++++++++ --->
<cfset tooltip.cantSubmit="<b>Needed to Submit</b>" & tooltip.wrng & "The ARA cannot be completed or submitted without contracts and controller input. Contact the system admin if they need to be added as ARA users.">

