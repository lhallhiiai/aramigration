create table AUS_UXS_NUC
(
    GRP           varchar(6)  not null,
    REORG_ID      varchar(20) not null,
    L4_REORG_NAME varchar(25)
)
go

create table Cat_Questions_Map
(
    id_question   int identity
        constraint PK_Cat_Questions_Map
            primary key,
    tab           varchar(30),
    catID_list    varchar(100),
    question      varchar(255),
    ods_or_user   varchar(20),
    tool_tip      varchar(255),
    display_order int,
    comment       varchar(255)
)
go

create table approval_grp
(
    id_approval        int identity,
    id_user            int,
    approval_group     varchar(10),
    approval_group_Old varchar(10),
    inactive           bit
        constraint DF_approval_grp_inactive default 0,
    created_by         int,
    created_on         datetime
        constraint DF_approval_grp_created_on default getdate(),
    modified_by        int,
    modified_on        datetime,
    id_role            int,
    id_job             int
)
go

create table ara_CP_Data
(
    COSTPT_NO    varchar(30),
    PROJ_NAME    varchar(25),
    CLIN         varchar(30) not null,
    START_DT     nvarchar(4000),
    END_DT       nvarchar(4000),
    PROJ_NAME2   varchar(25),
    PROJ_ORG     varchar(20) not null,
    OPS          varchar(20) not null,
    GRP          varchar(6)  not null,
    PROJ_TYPE_DC varchar(15) not null,
    PM           varchar(47) not null,
    CUST_NAME    varchar(25) not null
)
go

create table ara_CP_Reorg
(
    GRP           varchar(6)  not null,
    REORG_ID      varchar(20) not null,
    L4_REORG_NAME varchar(25)
)
go

create table ara_CP_Reorg_Old
(
    GRP           varchar(6)  not null,
    REORG_ID      varchar(20) not null,
    L4_REORG_NAME varchar(25)
)
go

create table ara_PM
(
    ara_PM_ID            int identity
        constraint PK_ara_PM
            primary key,
    ara_ID               int not null,
    fundsInAdvance       text,
    contractDefinization text,
    pertinentInformation text,
    workStarted          text,
    consequence          text,
    currentStatus        text,
    changeInScope        text,
    actionToClear        text,
    ES_Necessary         text,
    Other_necessary      text
)
go

create table ara_export_archive
(
    id_ara      int,
    exported_dt datetime
)
go

create table ara_export_file
(
    REC_TYPE              char,
    SUB_REC_TYPE          char(2),
    CLIN_NO               char(21) not null,
    IENT_NO               char(21),
    CNCT_NO               char(21),
    CLIN_DESC             char(30),
    START_DATE            char(8),
    END_DATE              char(8),
    BOOKING_DATE          char(8),
    CLIN_MNGR             char(9),
    EST_PRCT_COMP         char(7),
    ORGN_9                char(4),
    CLIN_COST_AMNT        char(15),
    CNCT_FUND_AMNT        char(15),
    PPY_PRCT              char(7),
    LOE_VARIANCE_PRCT     char(7),
    BILL_TYPE             char(2),
    BILL_STATUS           char,
    BILL_FREQ             char,
    OUTSIDE_POP           char,
    EXTRACT_CTD           char,
    POST_OVRN_TO_SALES    char,
    INVENTORY_OVERRUNS    char,
    BILL_OVERRUN          char,
    SPLIT_COST_REC        char,
    FUNDED_THRU_DATE      char(8),
    FEE_INCUR_ORG         char,
    CALC_FCCM             char,
    BRDN_FOR_MARKUP       char,
    LOE_LEVEL             char,
    LOE_HOURS             char(13),
    SORT_LENGTH           char(2),
    BTYP_CODE             char,
    BTYP_LEVEL_LAB        char,
    BTYP_LEVEL_ODC        char,
    BILL_UNPAID_AP        char,
    EXT_UP_TO_FUNDED      char,
    TM_REV_TYPE           char(2),
    LIQUIDATION_PRCT      char(7),
    RATE_CEILING          char,
    FEE_TYPE              char(2),
    FEE_CALC_START_DATE   char(8),
    FEE_LIMIT             char(15),
    FEE_FUND_LIMIT        char(15),
    AWARD_FEE_AMNT        char(15),
    AWARD_FEE_FUNDED      char(15),
    FEE_AMNT_PER_INV      char(15),
    FEE_RATE_PRCT         char(9),
    REV_FEE_PRCT          char(9),
    FCCM_CALC_START_DATE  char(8),
    REV_FEE_TYPE          char(2),
    REV_BRDN_TYPE         char,
    REV_LIMIT             char,
    REV_METHOD            char,
    REV_RECOGNIZE         char,
    REV_TANM_COST         char,
    REV_JOB_NO            char(21),
    REV_GL_ACCT           char(21),
    REV_AWARD_FEE_PRCT    char(7),
    RISK_FEE              char(15),
    RISK_COST             char(15),
    REV_BDGT_TYPE         char,
    REV_COS_METHOD        char,
    REV_COS_PRCT          char(9),
    REV_REV_PRCT          char(9),
    SUPP_SCH_FORMAT       char(3),
    PRINT_LEVEL_1         char,
    LVL_LENGTH_1          char(2),
    PRINT_FORMAT_1        char(3),
    PRINT_SF1034_1        char,
    PRINT_LEVEL_2         char,
    LVL_LENGTH_2          char(2),
    PRINT_FORMAT_2        char(3),
    PRINT_SF1034_2        char,
    PRINT_LEVEL_3         char,
    LVL_LENGTH_3          char(2),
    PRINT_FORMAT_3        char(3),
    PRINT_SF1034_3        char,
    PRINT_LEVEL_4         char,
    LVL_LENGTH_4          char(2),
    PRINT_FORMAT_4        char(3),
    PRINT_SF1034_4        char,
    PRINT_LEVEL_5         char,
    LVL_LENGTH_5          char(2),
    PRINT_FORMAT_5        char(3),
    PRINT_SF1034_5        char,
    RETENTION_TYPE        char,
    RETENTION_BASE        char,
    RETENTION_MAX         char(15),
    RETENTION_PRCT        char(7),
    RETENTION_LIMIT       char(15),
    START_AFTER_AMNT      char(15),
    TANM_SUBC             char,
    TANM_RANGE_TYPE       char,
    FROM_CLASS_1          char(4),
    THRU_CLASS_1          char(4),
    MARKUP_PRCT_1         char(7),
    FROM_CLASS_2          char(4),
    THRU_CLASS_2          char(4),
    MARKUP_PRCT_2         char(7),
    FROM_CLASS_3          char(4),
    THRU_CLASS_3          char(4),
    MARKUP_PRCT_3         char(7),
    FROM_CLASS_4          char(4),
    THRU_CLASS_4          char(4),
    MARKUP_PRCT_4         char(7),
    FROM_CLASS_5          char(4),
    THRU_CLASS_5          char(4),
    MARKUP_PRCT_5         char(7),
    FROM_CLASS_6          char(4),
    THRU_CLASS_6          char(4),
    MARKUP_PRCT_6         char(7),
    RISK_DATE             char(8),
    UDEF_X2_1             char(2),
    UDEF_X2_2             char(2),
    UDEF_X2_3             char(2),
    UDEF_X2_4             char(2),
    UDEF_X2_5             char(2),
    GOVT_CLIN             char(10),
    ITSC_CNCT             char(10),
    UDEF_X10_3            char(10),
    BUS_AREA              char(10),
    CUSTOMER              char(10),
    UDEF_DATE_1           char(8),
    UDEF_DATE_2           char(8),
    UDEF_DATE_3           char(8),
    UDEF_DATE_4           char(8),
    UDEF_DATE_5           char(8),
    UDEF_AMNT_1           char(13),
    UDEF_AMNT_2           char(13),
    UDEF_AMNT_3           char(13),
    UDEF_AMNT_4           char(13),
    UDEF_AMNT_5           char(13),
    ACRN_METHOD_COST_FEE  char,
    ACRN_METHOD_AWARD_FEE char,
    CNCT_CLIN_NO          char(6),
    CNCT_SLIN_NO          char(6),
    USE_AF_POOLS          char,
    USE_CNCT_LAB_CAT_FLAG char,
    REV_DATE_AT_RISK      char(8),
    ALLOC_EACH_JOB        char,
    ALLOC_JOB_NO          char(21),
    USER_INFO             char(40),
    INTERFACE             char(2),
    FILL                  char(1100)
)
go

create table ara_note
(
    id_note    int identity,
    id_ara     int,
    note       text,
    added_by   int,
    added_on   datetime,
    updated_by int,
    updated_on datetime
)
go

create table attach_checklist
(
    ID_attachtype  int identity
        constraint PK_attach_checklist
            primary key,
    catID_List     varchar(50),
    Short_desc     varchar(60),
    Long_Desc      varchar(500),
    display_order  int,
    who            varchar(50),
    status_Comment varchar(100)
)
go

create table category
(
    id_cat    int identity
        constraint PK__category__15502E78
            primary key nonclustered
                with (fillfactor = 100),
    catName   varchar(50),
    riskLevel int,
    color     varchar(50)
)
go

create table customerType
(
    id_customerType int identity
        constraint PK__customerType__20C1E124
            primary key nonclustered
                with (fillfactor = 100),
    description     varchar(50)
)
go

create table delegationLog
(
    id_delegation      int,
    fk_delegateFrom_ID int,
    fk_delegateTo_ID   int,
    delegateFrom_oprid varchar(50),
    delegateTo_oprid   varchar(50),
    startDate          datetime,
    endDate            datetime,
    dateadded          datetime,
    addedby            int,
    datemodified       datetime,
    modifiedby         int,
    action             varchar(20),
    action_taken_on    datetime,
    action_taken_by    varchar(50)
)
go

create table emailTypes
(
    id_emailtype     int identity
        constraint PK_emailTypes
            primary key,
    email_type       varchar(50),
    long_description varchar(255)
)
go

create table esReason
(
    id_esReason int identity
        constraint PK__esReason__173876EA
            primary key nonclustered
                with (fillfactor = 100),
    reason      varchar(50)
)
go

create table jobTitle
(
    id_job      int not null
        constraint PK_jobTitle
            primary key,
    title       varchar(100),
    description text,
    appOrder    int,
    inactive    bit
)
go

create table jobTitleBAK
(
    id_job      int identity
        constraint PK_jobTitleBAK
            primary key,
    title       varchar(100),
    description text,
    appOrder    int
)
go

create table rejectionReason
(
    id_Reason int identity
        constraint PK_rejectionReason
            primary key,
    reason    varchar(100),
    Descr     varchar(250)
)
go

create table revenueDescr
(
    id_revenue int identity,
    Descr      varchar(250)
)
go

create table role
(
    ID_role   int identity
        constraint PK__role__0DAF0CB0
            primary key nonclustered
                with (fillfactor = 100),
    roleName  varchar(50),
    roleShort varchar(50),
    roleDesc  varchar(200)
)
go

create table role_bak
(
    ID_role   int identity
        constraint PK__role__0DAF0CB0_BAK
            primary key nonclustered,
    roleName  varchar(50),
    roleShort varchar(50),
    roleDesc  varchar(200)
)
go

create table sector
(
    ID_sector  int not null
        constraint PK__sector__0BC6C43E
            primary key nonclustered
                with (fillfactor = 100),
    sectorName varchar(50)
)
go

create table status
(
    ID_status  int identity
        constraint PK__status__0425A276
            primary key nonclustered
                with (fillfactor = 100),
    statusName varchar(75),
    OneWord    varchar(50)
)
go

create table sysdiagrams
(
    name         sysname not null,
    principal_id int     not null,
    diagram_id   int identity
        primary key,
    version      int,
    definition   varbinary(max),
    constraint UK_principal_name
        unique (principal_id, name)
)
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'TABLE', 'sysdiagrams'
go

create table t_upload_JAMIS_file_email
(
    email_address varchar(500),
    emp_no        varchar(9)
)
go

create table thresholds
(
    id_threshold     int identity
        constraint PK_thresholds
            primary key,
    riskLevel        int,
    id_job           int,
    low_thresh       int,
    high_thresh      int,
    review_approve   varchar(20),
    delegate         int,
    added_byoprid    varchar(50),
    added_on         datetime,
    modified_byoprid varchar(50),
    modified_on      datetime
)
go

create table users
(
    id_user         int identity
        constraint PK_users
            primary key,
    emplID          varchar(50),
    oprid           varchar(50),
    password        varchar(100),
    ID_group        int,
    ID_sector       int,
    ID_role         int
        constraint FK_users_role
            references role,
    ID_job          int
        constraint FK_users_job
            references jobTitle,
    empname         varchar(500),
    first_name      varchar(100),
    last_name       varchar(100),
    CostCenter      varchar(50),
    Status          varchar(20),
    Inactive        bit,
    Approve_op      varchar(50),
    Approve_div     varchar(50),
    Approve_grp_OLD varchar(100),
    Approve_grp     varchar(500),
    created_by      int,
    created_on      datetime,
    modified_by     int,
    modified_on     datetime,
    ALNoprid        varchar(50),
    email           varchar(50),
    TSDEmail        varchar(50)
)
go

create table ara
(
    id_ara             int identity
        constraint PK__ara__117F9D94
            primary key nonclustered,
    id_cat             int
        constraint FK__ara__id_cat__30F848ED
            references category,
    id_user            int
        constraint FK_dbo_ara_4
            references users,
    id_status          int
        constraint FK_ara_status
            references status,
    division           varchar(50),
    reference          varchar(50),
    revision           int,
    title              varchar(500),
    customerName       varchar(500),
    contractNo         varchar(50),
    doNo               varchar(50),
    jamisNo            varchar(50),
    contractType       varchar(50),
    amountTotal        money,
    amountRequested    money,
    totalAnticipated   money,
    percentAnticipated float,
    startDate          datetime,
    expirationDate     datetime,
    isEarlyStart       bit,
    ID_esReason        int
        constraint FK_dbo_ara_3
            references esReason,
    esOther            text,
    OMSNum             varchar(50),
    ID_Revenue         int,
    ID_PM              int,
    ID_Contract        int,
    ID_Controller      int,
    company            varchar(10),
    isEAC              varchar(5),
    ID_OpsVP           int
)
go

create table araAppLog
(
    id_araAppLog       int identity
        constraint PK_araAppLog
            primary key,
    id_ara             int
        constraint FK_araAppLog_ara
            references ara,
    id_user            int,
    id_job             int
        constraint FK_araAppLog_jobTitle
            references jobTitle,
    id_status          int,
    isRejection        bit,
    comment            text,
    approvalDate       datetime,
    cycle              int,
    id_reason          int,
    Rej_areas          varchar(100),
    oprid_delegateFrom varchar(50),
    oprid_delegateTo   varchar(50)
)
go

create table ara_cm
(
    id_ara_cm                      int identity
        constraint PK__ara_cm__1CF15040
            primary key nonclustered
                with (fillfactor = 100),
    id_ara                         int
        constraint FK_ara_cm_ara
            references ara,
    id_user                        int
        constraint FK_ara_cm_users
            references users,
    id_customerType                int
        constraint FK_ara_cm_customerType
            references customerType,
    contractType                   varchar(50),
    authStart                      datetime,
    executionDate                  datetime,
    customerPO                     varchar(50),
    POContactDate                  datetime,
    PCCostAuth                     money,
    fundsToSupport                 int,
    fundsExplanation               text,
    creditCheck                    int,
    creditExplanation              text,
    allApprovals                   int,
    allApprovalsExplanation        text,
    forwarded                      int,
    forwardedExplanation           text,
    workAuthorization              int,
    workAuthorizationExplanation   text,
    authType                       varchar(70),
    writtenConfirmation            int,
    writtenConfirmationExplanation varchar(70),
    alion_conf                     int,
    Alion_confExplanation          varchar(70),
    anticipatoryCost               int,
    anticipatoryCostExplanation    varchar(70),
    anticipatedNegotiation         datetime,
    CACertification                datetime,
    estModExeDate                  datetime,
    intClearCompDate               datetime,
    pop                            text,
    poolAmt                        float,
    estFunDate                     datetime,
    pop2                           datetime
)
go

create table ara_con
(
    id_ara_con     int identity
        constraint PK__ara_con__1ED998B2
            primary key nonclustered,
    id_ara         int
        constraint FK_ara_con_ara
            references ara,
    id_user        int
        constraint FK_ara_con_users
            references users,
    interestImpact float,
    burnRate       float,
    total_cost     float,
    total_fee      float,
    icCost         float,
    icFee          float,
    company        varchar(10)
)
go

create table attachments
(
    id_attachment int identity
        constraint PK__attachments__2C3393D0
            primary key nonclustered
                with (fillfactor = 100),
    id_ara        int
        constraint FK_attachments_ara
            references ara,
    id_user       int
        constraint FK_attachments_users
            references users,
    filename      varchar(100),
    fileType      varchar(50),
    description   varchar(255),
    date          datetime,
    Filesize      int,
    MimeType      varchar(100),
    binary_file   varbinary(max)
)
go

create table clins
(
    id_clins       int identity
        constraint PK__clins__267ABA7A
            primary key nonclustered
                with (fillfactor = 100),
    id_ara         int
        constraint FK_clins_ara
            references ara,
    clinNo         varchar(50),
    description    text,
    expirationDate datetime,
    revisionAmt    money,
    costFunding    money,
    feeFunding     money,
    total          money,
    CameFromJamis  int,
    negate         varchar(5)
        constraint DF_clins_negate default 0
)
go

create table delegation
(
    id_delegation      int identity
        constraint PK__delegation__060DEAE8
            primary key nonclustered
                with (fillfactor = 100),
    fk_delegateFrom_ID int
        constraint FK_delegation_users
            references users,
    fk_delegateTo_ID   int,
    delegateFrom_oprid varchar(50),
    delegateTo_oprid   varchar(50),
    startDate          datetime,
    endDate            datetime,
    dateadded          datetime,
    addedby            int,
    datemodified       datetime,
    modifiedby         int
)
go

create table emailLog
(
    id_emailLog   int identity
        constraint PK__emailLog__300424B4
            primary key nonclustered
                with (fillfactor = 100),
    id_ara        int
        constraint FK_emailLog_ara
            references ara,
    id_emailType  int,
    subject       text,
    MsgTo         varchar(500),
    MsgCC         varchar(500),
    message_pdf   varbinary(max),
    sentDate      datetime
        constraint DF_emailLog_sentDate default getdate(),
    statusID      int,
    id_araAppLog  int,
    id_delegation int
)
go

create table logbook
(
    id_logbook int identity
        constraint PK__logbook__023D5A04
            primary key nonclustered,
    id_user    int
        constraint FK_logbook_users
            references users,
    id_ara     int
        constraint FK_logbook_ara
            references ara,
    event      varchar(500),
    url        varchar(150),
    timestamp  datetime
        constraint DF_logbook_timestamp default getdate()
)
go

create table userAccessForm
(
    id_form     int identity
        constraint PK_userAccessForm
            primary key,
    id_user     int not null
        constraint FK_userAccessForm_user
            references users,
    action      varchar(10),
    ID_role     int
        constraint FK_userAccessForm_role
            references role,
    ID_job      int
        constraint FK_userAccessForm_job
            references jobTitle,
    access_form varbinary(max),
    created_by  int,
    created_on  datetime,
    mime_type   varchar(100),
    file_name   varchar(100)
)
go

create table users_Delete
(
    id_user         int identity
        constraint PK_users1
            primary key,
    emplID          varchar(50),
    oprid           varchar(50),
    password        varchar(100),
    ID_group        int,
    ID_sector       int,
    ID_role         int
        constraint FK_users_role1
            references role,
    ID_job          int
        constraint FK_users_job1
            references jobTitle,
    empname         varchar(500),
    first_name      varchar(100),
    last_name       varchar(100),
    CostCenter      varchar(50),
    Status          varchar(20),
    Inactive        bit,
    Approve_op      varchar(50),
    Approve_div     varchar(50),
    Approve_grp_OLD varchar(100),
    Approve_grp     varchar(500),
    created_by      int,
    created_on      datetime,
    modified_by     int,
    modified_on     datetime,
    ALNoprid        varchar(50),
    email           varchar(50)
)
go

create table araAppList
(
    ID_araAppList          int identity
        constraint PK__araAppList__0F975522
            primary key nonclustered,
    id_ara                 int
        constraint FK_araAppList_ara
            references ara,
    programManager         int
        constraint FK_araAppList_users
            references users,
    contractAdmin          int
        constraint FK_araAppList_users1
            references users,
    controller             int
        constraint FK_araAppList_users2
            references users_Delete,
    groupContractsManager  int
        constraint FK_araAppList_users3
            references users,
    groupController        int
        constraint FK_araAppList_users4
            references users,
    divisionManager        int
        constraint FK_araAppList_users5
            references users,
    operationManager       int
        constraint FK_araAppList_users6
            references users,
    groupManager           int
        constraint FK_araAppList_users7
            references users,
    sectorContractsManager int
        constraint FK_araAppList_users8
            references users,
    sectorController       int
        constraint FK_araAppList_users9
            references users,
    sectorManager          int
        constraint FK_araAppList_users10
            references users,
    cao                    int
        constraint FK_araAppList_users11
            references users,
    cfo                    int
        constraint FK_araAppList_users12
            references users,
    coo                    int
        constraint FK_araAppList_users13
            references users,
    ceo                    int
        constraint FK_araAppList_users14
            references users,
    cycle                  int
)
go

CREATE VIEW dbo.v_approvals
AS
SELECT     dbo.araAppLog.id_araAppLog, dbo.araAppLog.id_ara, dbo.araAppLog.id_user, dbo.araAppLog.id_job, dbo.araAppLog.isRejection,
                      dbo.araAppLog.comment, dbo.araAppLog.approvalDate, dbo.araAppLog.cycle, dbo.users.empname, dbo.jobTitle.title, dbo.sector.sectorName,
                      dbo.jobTitle.appOrder
FROM         dbo.araAppLog LEFT OUTER JOIN
                      dbo.users ON dbo.araAppLog.id_user = dbo.users.id_user LEFT OUTER JOIN
                      dbo.sector ON dbo.users.ID_sector = dbo.sector.ID_sector LEFT OUTER JOIN
                      dbo.jobTitle ON dbo.araAppLog.id_job = dbo.jobTitle.id_job AND dbo.users.ID_job = dbo.jobTitle.id_job
go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties =
   Begin PaneConfigurations =
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[19] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane =
      Begin Origin =
         Top = 0
         Left = 0
      End
      Begin Tables =
         Begin Table = "araAppLog"
            Begin Extent =
               Top = 6
               Left = 38
               Bottom = 114
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "users"
            Begin Extent =
               Top = 117
               Left = 224
               Bottom = 225
               Right = 375
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "sector"
            Begin Extent =
               Top = 6
               Left = 416
               Bottom = 84
               Right = 567
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "jobTitle"
            Begin Extent =
               Top = 84
               Left = 605
               Bottom = 192
               Right = 756
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane =
   End
   Begin DataPane =
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane =
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'v_approvals'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 1, 'SCHEMA', 'dbo', 'VIEW', 'v_approvals'
go


CREATE VIEW [dbo].[v_ara]
AS
SELECT        dbo.ara.id_ara, dbo.ara.id_cat, dbo.ara.id_user, dbo.ara.id_status, dbo.ara.ID_PM, dbo.ara.ID_Contract, dbo.ara.ID_Controller, dbo.ara.ID_OpsVP, dbo.ara.reference, dbo.ara.revision, dbo.ara.title, dbo.ara.customerName,
                         dbo.ara.contractNo, dbo.ara.doNo, dbo.ara.jamisNo, dbo.ara.contractType, dbo.ara.amountTotal, dbo.ara.amountRequested, dbo.ara.totalAnticipated, dbo.ara.percentAnticipated, dbo.ara.startDate, dbo.ara.expirationDate,
                         dbo.ara.isEarlyStart, dbo.ara.ID_esReason, dbo.ara.esOther, dbo.ara.ID_Revenue, dbo.ara.OMSNum, dbo.status.statusName, org.sctr AS Sector, org.grp, org.oprtn AS op, dbo.ara.division, dbo.status.OneWord,
                             (SELECT        empname
                               FROM            dbo.users
                               WHERE        (id_user = dbo.ara.id_user)) AS CreatorName,
                             (SELECT        empname
                               FROM            dbo.users AS users_3
                               WHERE        (id_user = dbo.ara.ID_PM)) AS PMName,
                             (SELECT        empname
                               FROM            dbo.users AS users_2
                               WHERE        (id_user = dbo.ara.ID_Contract)) AS contractName,
                             (SELECT        empname
                               FROM            dbo.users AS users_1
                               WHERE        (id_user = dbo.ara.ID_Controller)) AS controllerName, dbo.category.riskLevel, dbo.category.catName, dbo.ara.company
FROM            dbo.ara LEFT OUTER JOIN
                         dbo.status ON dbo.ara.id_status = dbo.status.ID_status LEFT OUTER JOIN
                             (SELECT        org, prnt_node, org_lvl, org_type, org_abbr, org_desc, org_mngr, sctr, grp, oprtn, dvsn, cost_center
                               FROM            cae_ods.dbo.org AS org_1
                               WHERE        (org_type = 'division')) AS org ON dbo.ara.division = org.dvsn INNER JOIN
                         dbo.category ON dbo.ara.id_cat = dbo.category.id_cat
go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties =
   Begin PaneConfigurations =
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane =
      Begin Origin =
         Top = 0
         Left = 0
      End
      Begin Tables =
         Begin Table = "ara"
            Begin Extent =
               Top = 2
               Left = 197
               Bottom = 117
               Right = 369
            End
            DisplayFlags = 280
            TopColumn = 24
         End
         Begin Table = "status"
            Begin Extent =
               Top = 0
               Left = 394
               Bottom = 100
               Right = 546
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "org"
            Begin Extent =
               Top = 101
               Left = 447
               Bottom = 216
               Right = 599
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "category"
            Begin Extent =
               Top = 62
               Left = 12
               Bottom = 222
               Right = 164
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane =
   End
   Begin DataPane =
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 35
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
        ', 'SCHEMA', 'dbo', 'VIEW', 'v_ara'
go

exec sp_addextendedproperty 'MS_DiagramPane2', N' Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane =
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'v_ara'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 2, 'SCHEMA', 'dbo', 'VIEW', 'v_ara'
go


CREATE VIEW [dbo].[v_clin]
AS
SELECT     TOP (100) PERCENT a.id_ara, a.id_status, ISNULL(SUM(a.amountTotal), 0) AS ara_total, ISNULL(SUM(c.total), 0) AS clin_total, a.id_cat
FROM         dbo.ara AS a LEFT OUTER JOIN
                      dbo.clins AS c ON a.id_ara = c.id_ara
GROUP BY a.id_ara, a.id_status, a.id_cat
ORDER BY a.id_ara

go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties =
   Begin PaneConfigurations =
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane =
      Begin Origin =
         Top = 0
         Left = 0
      End
      Begin Tables =
         Begin Table = "a"
            Begin Extent =
               Top = 6
               Left = 38
               Bottom = 121
               Right = 226
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent =
               Top = 6
               Left = 264
               Bottom = 121
               Right = 438
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane =
   End
   Begin DataPane =
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane =
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'v_clin'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 1, 'SCHEMA', 'dbo', 'VIEW', 'v_clin'
go

CREATE VIEW dbo.v_emailLog
AS
SELECT     TOP (100) PERCENT id_emailLog, id_ara, id_emailType, subject, MsgTo, MsgCC, message_pdf, sentDate, statusID,
                          (SELECT     comment
                            FROM          dbo.araAppLog
                            WHERE      (id_araAppLog = dbo.emailLog.id_araAppLog)) AS comment,
                          (SELECT     oprid_delegateTo
                            FROM          dbo.araAppLog AS araAppLog_2
                            WHERE      (id_araAppLog = dbo.emailLog.id_araAppLog)) AS oprid_deleteFrom,
                          (SELECT     oprid_delegateFrom
                            FROM          dbo.araAppLog AS araAppLog_1
                            WHERE      (id_araAppLog = dbo.emailLog.id_araAppLog)) AS oprid_deleteTo,
                          (SELECT     statusName
                            FROM          dbo.status
                            WHERE      (ID_status = dbo.emailLog.statusID)) AS statusName
FROM         dbo.emailLog
WHERE     (id_emailType = 1)
ORDER BY sentDate, statusID
go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties =
   Begin PaneConfigurations =
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane =
      Begin Origin =
         Top = 0
         Left = 0
      End
      Begin Tables =
         Begin Table = "emailLog"
            Begin Extent =
               Top = 6
               Left = 38
               Bottom = 125
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane =
   End
   Begin DataPane =
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane =
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'v_emailLog'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 1, 'SCHEMA', 'dbo', 'VIEW', 'v_emailLog'
go









CREATE VIEW [dbo].[v_users]
AS
SELECT     dbo.users.id_user, dbo.users.Inactive,dbo.users.email, dbo.users.emplID, dbo.users.oprid, dbo.users.empname, dbo.users.last_name, dbo.users.first_name,
                      dbo.role.roleName, dbo.jobTitle.title, dbo.users.ID_role, dbo.users.ID_job, dbo.jobTitle.appOrder, dbo.delegation.fk_delegateTo_ID,
                      dbo.delegation.delegateTo_oprid, org.sctr, org.grp, org.oprtn, org.dvsn, org.org_desc, org.cost_center, dbo.jobTitle.title AS DelegateJobtitle,
                      dbo.users.password, dbo.users.Approve_grp, dbo.users.Approve_div, dbo.users.Approve_op
FROM         dbo.users LEFT OUTER JOIN
                      dbo.delegation ON dbo.users.id_user = dbo.delegation.fk_delegateFrom_ID AND dbo.delegation.startDate <= GETDATE() AND
                      dbo.delegation.endDate > GETDATE() LEFT OUTER JOIN
                      dbo.role ON dbo.users.ID_role = dbo.role.ID_role LEFT OUTER JOIN
                      dbo.jobTitle ON dbo.users.ID_job = dbo.jobTitle.id_job LEFT OUTER JOIN
                      cae_ods.dbo.empl AS empl ON dbo.users.emplID=empl.empl_nmbr LEFT OUTER JOIN
                      cae_ods.dbo.org AS org ON empl.cost_cntr = org.cost_center







go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties =
   Begin PaneConfigurations =
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[50] 4[4] 2[25] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane =
      Begin Origin =
         Top = 0
         Left = 0
      End
      Begin Tables =
         Begin Table = "users"
            Begin Extent =
               Top = 13
               Left = 281
               Bottom = 215
               Right = 432
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "delegation"
            Begin Extent =
               Top = 2
               Left = 753
               Bottom = 214
               Right = 931
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "role"
            Begin Extent =
               Top = 13
               Left = 27
               Bottom = 121
               Right = 178
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "jobTitle"
            Begin Extent =
               Top = 3
               Left = 476
               Bottom = 116
               Right = 627
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "org"
            Begin Extent =
               Top = 126
               Left = 38
               Bottom = 245
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane =
   End
   Begin DataPane =
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 16
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
', 'SCHEMA', 'dbo', 'VIEW', 'v_users'
go

exec sp_addextendedproperty 'MS_DiagramPane2', N'
         Width = 1500
      End
   End
   Begin CriteriaPane =
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'v_users'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 2, 'SCHEMA', 'dbo', 'VIEW', 'v_users'
go


-- =============================================
-- Author:		Louis Hall
-- Create date: 8/20/2024
-- Description:	This gets the outstanding approvals for a user for display in the ApprovalDashboard
-- =============================================
CREATE PROCEDURE [dbo].[ApprovalsGetByID]
    @upn VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @divisionList TABLE (division VARCHAR(10));
        DECLARE @idjob AS INT;
        DECLARE @userid AS INT;

        INSERT INTO @divisionList (division)
        SELECT Value
        FROM dbo.SplitString((SELECT Approve_grp FROM v_users WHERE oprid = @upn), ',');

        SET @idjob = (SELECT id_job FROM v_users WHERE oprid = @upn);
        SET @userid = (SELECT id_user FROM v_users WHERE oprid = @upn);

        DROP TABLE IF EXISTS #tmpApprovals;

        SELECT ara.id_ara,
               ara.id_status,
               ara.id_user,
               ara.ID_Contract,
               ara.id_pm,
               ara.id_controller,
               ara.id_cat,
               category.riskLevel,
               ara.amountTotal,
               ara.division,
               thresholds.low_thresh,
               thresholds.high_thresh,
               jobTitle.title,
               jobTitle.appOrder,
               thresholds.id_job
        INTO #tmpApprovals
        FROM ara
        INNER JOIN category ON ara.id_cat = category.id_cat
        INNER JOIN thresholds ON category.riskLevel = thresholds.riskLevel
        INNER JOIN jobTitle ON thresholds.id_job = jobTitle.id_job
        WHERE ara.id_ara IN (
            SELECT id_ara
            FROM v_ara
            WHERE division IN (SELECT division FROM @divisionList)
              AND id_status IN (2, 4, 6)
        )
        AND jobTitle.apporder IS NOT NULL
        AND jobTitle.id_job >= 1
        AND thresholds.low_thresh <= ara.amountTotal
        AND thresholds.id_job = @idjob
        ORDER BY id_ara, jobTitle.appOrder;

        DELETE FROM #tmpApprovals WHERE id_job <> @idjob;

        IF @idjob = 2
        BEGIN
            DELETE FROM #tmpApprovals WHERE ID_Contract <> @userid;
            DELETE FROM #tmpApprovals WHERE id_status <> 2;
        END
        ELSE IF @idjob = 3
        BEGIN
            DELETE FROM #tmpApprovals WHERE id_controller <> @userid;
            DELETE FROM #tmpApprovals WHERE id_status <> 4;
        END
        ELSE IF @idjob = 4
        BEGIN
            DELETE FROM #tmpApprovals WHERE id_pm <> @userid;
        END
        ELSE
        BEGIN
            DELETE FROM #tmpApprovals WHERE id_status <> 6;

            DROP TABLE IF EXISTS #next;
            SELECT a.id_ara, a.id_job, t.appOrder
            INTO #next
            FROM araAppLog a
            JOIN jobTitle t ON t.id_job = a.id_job
            WHERE a.id_ara IN (SELECT id_ara FROM #tmpApprovals);

            DROP TABLE IF EXISTS #currentSteps;
            SELECT n.id_ara, MAX(n.appOrder) + 1 AS CurrentStep
            INTO #currentSteps
            FROM #next n
            GROUP BY n.id_ara;

            DROP TABLE IF EXISTS #allCurrentJobIds;
            SELECT c.*, t.id_job, t.description
            INTO #allCurrentJobIds
            FROM #currentSteps c
            JOIN jobTitle t ON c.CurrentStep = t.appOrder;

            DELETE FROM #tmpApprovals
            WHERE id_ara IN (
                SELECT id_ara FROM #allCurrentJobIds WHERE id_job <> @idjob
            );
        END

        SELECT DISTINCT
            a.id_ara,
            LINK = '',
            ID = RIGHT('0000' + ISNULL(CAST(a.id_ara AS VARCHAR(4)), ''), 8) + '-' + CAST(a.revision AS VARCHAR(2)) +
                 '<br />Expiration:  ' + CAST(FORMAT(a.expirationDate, 'dd/MM/yyyy ') AS VARCHAR(10)),
            UPPER('RISK:  ' + CAST(a.riskLevel AS VARCHAR(2)) + ', CATEGORY:  ' + a.catName) AS Title,
            a.customerName,
            a.amountTotal
        FROM (
            SELECT ara.id_ara,
                   ara.revision,
                   ara.expirationDate,
                   ara.id_cat,
                   category.riskLevel,
                   category.catName,
                   ara.customerName,
                   ara.amountTotal
            FROM ara
            INNER JOIN category ON ara.id_cat = category.id_cat
            INNER JOIN thresholds ON category.riskLevel = thresholds.riskLevel
            INNER JOIN jobTitle ON thresholds.id_job = jobTitle.id_job
            WHERE ara.id_ara IN (SELECT id_ara FROM #tmpApprovals)
              AND jobTitle.apporder IS NOT NULL
              AND jobTitle.id_job >= 1
              AND thresholds.low_thresh <= ara.amountTotal
        ) AS a
        INNER JOIN araAppLog b ON a.id_ara = b.id_ara
        AND b.id_ara IN (SELECT id_ara FROM #tmpApprovals);
    END TRY

    BEGIN CATCH
        DECLARE @ERRMSG NVARCHAR(4000), @ERRSEVERITY INT;
        SELECT @ERRMSG = ERROR_MESSAGE(),
               @ERRSEVERITY = ERROR_SEVERITY();
        RAISERROR (@ERRMSG, @ERRSEVERITY, 1);
    END CATCH
END

go


-- =============================================
-- Author:		Grace Yao
-- Create date: 7/2/25
-- Description:	This gets the outstanding approvals for a user as well as the ones delegated to the user and for display in the ApprovalDashboard
-- =============================================
CREATE PROCEDURE [dbo].[ApprovalsGetByID_PlusDelegation]
    @upn VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

	DECLARE @oprid as varchar(50);
	DECLARE @delegated as int;
	DECLARE @ApprovalsAll TABLE(id_ara int, delegated int, oprid varchar(50))

	IF CURSOR_STATUS('global', 'curApprovers')>=-1
	BEGIN
		CLOSE curApprovers;
		DEALLOCATE  curApprovers;
	END

	DECLARE curApprovers CURSOR FOR
	SELECT delegateFrom_oprid as oprid, 1 as delegated
	FROM dbo.delegation
	WHERE delegateTo_oprid=@upn and getdate() between startDate and endDate
	UNION
	SELECT @upn, 0

	OPEN curApprovers
	FETCH NEXT FROM curApprovers INTO @oprid, @delegated
	WHILE @@FETCH_STATUS=0

	BEGIN

        DECLARE @divisionList TABLE (division VARCHAR(10));
        DECLARE @idjob AS INT;
        DECLARE @userid AS INT;

		DELETE FROM @divisionList;

        INSERT INTO @divisionList (division)
        SELECT Value
        FROM dbo.SplitString((SELECT Approve_grp FROM v_users WHERE oprid = @oprid), ',');

        SET @idjob = (SELECT id_job FROM v_users WHERE oprid = @oprid);
        SET @userid = (SELECT id_user FROM v_users WHERE oprid = @oprid);

		DROP TABLE IF EXISTS #tmpApprovals;

        SELECT ara.id_ara,
               ara.id_status,
               ara.id_user,
               ara.ID_Contract,
               ara.id_pm,
               ara.id_controller,
               ara.id_cat,
               category.riskLevel,
               ara.amountTotal,
               ara.division,
               thresholds.low_thresh,
               thresholds.high_thresh,
               jobTitle.title,
               jobTitle.appOrder,
               thresholds.id_job
        INTO #tmpApprovals
        FROM ara
        INNER JOIN category ON ara.id_cat = category.id_cat
        INNER JOIN thresholds ON category.riskLevel = thresholds.riskLevel
        INNER JOIN jobTitle ON thresholds.id_job = jobTitle.id_job
        WHERE ara.id_ara IN (
            SELECT id_ara
            FROM v_ara
            WHERE division IN (SELECT division FROM @divisionList)
              AND id_status IN (2, 4, 6)
        )
        AND jobTitle.apporder IS NOT NULL
        AND jobTitle.id_job >= 1
        AND thresholds.low_thresh <= ara.amountTotal
        AND thresholds.id_job = @idjob
        ORDER BY id_ara, jobTitle.appOrder;

        DELETE FROM #tmpApprovals WHERE id_job <> @idjob;


        IF @idjob = 2
        BEGIN
            DELETE FROM #tmpApprovals WHERE ID_Contract <> @userid;
            DELETE FROM #tmpApprovals WHERE id_status <> 2;
        END
        ELSE IF @idjob = 3
        BEGIN
            DELETE FROM #tmpApprovals WHERE id_controller <> @userid;
            DELETE FROM #tmpApprovals WHERE id_status <> 4;
        END
        ELSE IF @idjob = 4
        BEGIN
            DELETE FROM #tmpApprovals WHERE id_pm <> @userid;
        END
        ELSE
        BEGIN
            DELETE FROM #tmpApprovals WHERE id_status <> 6;

            DROP TABLE IF EXISTS #next;
            SELECT a.id_ara, a.id_job, t.appOrder
            INTO #next
            FROM araAppLog a
            JOIN jobTitle t ON t.id_job = a.id_job
            WHERE a.id_ara IN (SELECT id_ara FROM #tmpApprovals);

            DROP TABLE IF EXISTS #currentSteps;
            SELECT n.id_ara, MAX(n.appOrder) + 1 AS CurrentStep
            INTO #currentSteps
            FROM #next n
            GROUP BY n.id_ara;

            DROP TABLE IF EXISTS #allCurrentJobIds;
            SELECT c.*, t.id_job, t.description
            INTO #allCurrentJobIds
            FROM #currentSteps c
            JOIN jobTitle t ON c.CurrentStep = t.appOrder;

            DELETE FROM #tmpApprovals
            WHERE id_ara IN (
                SELECT id_ara FROM #allCurrentJobIds WHERE id_job <> @idjob
            );

        END

		INSERT INTO @ApprovalsAll
		SELECT id_ara, @delegated , @oprid
		FROM #tmpApprovals;

		FETCH NEXT FROM curApprovers INTO @oprid, @delegated

	END;
	CLOSE curApprovers;
	DEALLOCATE curApprovers;

      SELECT DISTINCT
            a.id_ara,
			t.delegated,
            LINK = '',
            ID = RIGHT('0000' + ISNULL(CAST(a.id_ara AS VARCHAR(4)), ''), 8) + '-' + CAST(a.revision AS VARCHAR(2)) +
                 '<br />Expiration:  ' + CAST(FORMAT(a.expirationDate, 'dd/MM/yyyy ') AS VARCHAR(10)),
            UPPER('RISK:  ' + CAST(category.riskLevel AS VARCHAR(2)) + ', CATEGORY:  ' + category.catName) AS Title,
            a.customerName,
            a.amountTotal
        FROM ara a
            INNER JOIN category ON a.id_cat = category.id_cat
            INNER JOIN thresholds ON category.riskLevel = thresholds.riskLevel
            INNER JOIN jobTitle ON thresholds.id_job = jobTitle.id_job
			INNER JOIN araAppLog b ON a.id_ara = b.id_ara
			INNER JOIN @ApprovalsAll t ON a.id_ara = t.id_ara
        WHERE jobTitle.apporder IS NOT NULL
              AND jobTitle.id_job >= 1
              AND thresholds.low_thresh <= a.amountTotal

    END TRY

    BEGIN CATCH
        DECLARE @ERRMSG NVARCHAR(4000), @ERRSEVERITY INT;
        SELECT @ERRMSG = ERROR_MESSAGE(),
               @ERRSEVERITY = ERROR_SEVERITY();
        RAISERROR (@ERRMSG, @ERRSEVERITY, 1);
    END CATCH
END

go


CREATE FUNCTION [dbo].[SplitString]
(
    @Input NVARCHAR(MAX),
    @Delimiter CHAR(1)
)
RETURNS @Output TABLE (Value VARCHAR(100))
AS
BEGIN
    DECLARE @Start INT = 1, @End INT;

    WHILE CHARINDEX(@Delimiter, @Input, @Start) > 0
    BEGIN
        SET @End = CHARINDEX(@Delimiter, @Input, @Start);
        INSERT INTO @Output (Value)
        VALUES (LTRIM(RTRIM(SUBSTRING(@Input, @Start, @End - @Start))));
        SET @Start = @End + 1;
    END;

    INSERT INTO @Output (Value)
    VALUES (LTRIM(RTRIM(SUBSTRING(@Input, @Start, LEN(@Input) - @Start + 1))));

    RETURN;
END;
go


	CREATE FUNCTION dbo.fn_diagramobjects()
	RETURNS int
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		declare @id_upgraddiagrams		int
		declare @id_sysdiagrams			int
		declare @id_helpdiagrams		int
		declare @id_helpdiagramdefinition	int
		declare @id_creatediagram	int
		declare @id_renamediagram	int
		declare @id_alterdiagram 	int
		declare @id_dropdiagram		int
		declare @InstalledObjects	int

		select @InstalledObjects = 0

		select 	@id_upgraddiagrams = object_id(N'dbo.sp_upgraddiagrams'),
			@id_sysdiagrams = object_id(N'dbo.sysdiagrams'),
			@id_helpdiagrams = object_id(N'dbo.sp_helpdiagrams'),
			@id_helpdiagramdefinition = object_id(N'dbo.sp_helpdiagramdefinition'),
			@id_creatediagram = object_id(N'dbo.sp_creatediagram'),
			@id_renamediagram = object_id(N'dbo.sp_renamediagram'),
			@id_alterdiagram = object_id(N'dbo.sp_alterdiagram'),
			@id_dropdiagram = object_id(N'dbo.sp_dropdiagram')

		if @id_upgraddiagrams is not null
			select @InstalledObjects = @InstalledObjects + 1
		if @id_sysdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 2
		if @id_helpdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 4
		if @id_helpdiagramdefinition is not null
			select @InstalledObjects = @InstalledObjects + 8
		if @id_creatediagram is not null
			select @InstalledObjects = @InstalledObjects + 16
		if @id_renamediagram is not null
			select @InstalledObjects = @InstalledObjects + 32
		if @id_alterdiagram  is not null
			select @InstalledObjects = @InstalledObjects + 64
		if @id_dropdiagram is not null
			select @InstalledObjects = @InstalledObjects + 128

		return @InstalledObjects
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'FUNCTION', 'fn_diagramobjects'
go

grant execute on fn_diagramobjects to [public]
go


-- =============================================
-- Author:		Grace Yao
-- Create date: 03/15/2012
-- Description:	This is a sp created to load the ARA export table that is used to create flatfile to be imported into JAMIS
-- =============================================
-- CHANGE LOG
-- Date			Author			Change
-- 4/24/2012	Grace Yao		Add company variable(v_instance) per request
-- 4/26/2012	Grace Yao		Change risk fee/cost to 1 cent when it is zero. JAMIS gives error importing a zero fee/cost.
-- 6/22/2012	Grace Yao		Exclude early start ara from export because they dont have clin_no
-- 12/17/12		Grace Yao		Use job_master table in cae-ods instead of the one in jobcost. Jobcose will be removed from cae-sql
-- 06/25/2013	Grace Yao		Replace truncate with delete so cf_ara does not have to be db_owner, for SOX compliance
-- 10/03/2013	Grace Yao		Pull [BRDN_FOR_MARKUP] flag from JAMIS, if it does no exist in JAMIS, default to 'Y'
-- =============================================

CREATE procedure [dbo].[p_build_ARA_export](@v_instance varchar(25))
as
begin
declare @v_step_name varchar(25);
set @v_step_name = 'ExportARA_'+@v_instance;

--truncate table dbo.ara_export_file
delete from dbo.ara_export_file	 --GYAO, 6/25/13: replace truncate with delete
insert into dbo.ara_export_file
		(rec_type
		, sub_rec_type
		, clin_no
		, ient_no
		, cnct_no
		, BRDN_FOR_MARKUP
		, risk_fee
		, risk_cost
		, rev_date_at_risk
		, user_info
		, interface
		, fill
		)
		select
		'2' as rec_type
		, '03' as sub_rec_type
		, clin_no
		, ient_no
		, cnct_no
		, case when isnull(c.BRDN_FOR_MARKUP,'')='' then 'Y' else c.BRDN_FOR_MARKUP end as BRDN_FOR_MARKUP		--GYAO,10/3/13: use JAMIS value or default to 'Y'
		, case when feeFunding=0 then '+00000000000.01' when feeFunding < 0 then '-'+replicate('0',14-len(abs(feeFunding)))+(cast(abs(feeFunding) as varchar)) else '+'+replicate('0',14-len(abs(feeFunding)))+(cast(abs(feeFunding) as varchar)) end as risk_fee--14
		, case when costFunding=0 then '+00000000000.01' when costFunding < 0 then '-'+replicate('0',14-len(abs(costFunding)))+(cast(abs(costFunding) as varchar)) else '+'+replicate('0',14-len(abs(costFunding)))+(cast(abs(costFunding) as varchar)) end as risk_cost--14
		, convert(varchar(8), r.expirationDate, 112) as rev_date_at_risk
		, convert(char(40),'') as user_info
		, convert(char(2),'') as interface
		, convert(char(1100),'')as fill

	  from dbo.ara r inner join dbo.clins a on r.id_ara=a.id_ara
		left outer join cae_ods.jobcost.t_clin_master c on a.clinNo=c.clin_no
	  where
		r.id_status=12
		and r.company=@v_instance
		and r.id_cat<>10; --GYao, 6/22/2012: exclude early start ara because they dont have clin_no


EXEC msdb.dbo.sp_start_job @job_name='ExportARA', @step_name=@v_step_name;

--log exported clins
insert into dbo.ara_export_archive
	(id_ara
	, exported_dt
	)
select distinct
    r.id_ara
	, getdate()
from dbo.ara_export_file e inner join dbo.clins c on e.clin_no=c.clinNo inner join dbo.ara r on r.id_ara=c.id_ara
where r.id_status=12 and r.company=@v_instance

--change the ara status to "Exported"

update dbo.ara
set id_status=13
where id_ara in (select distinct id_ara from dbo.ara_export_archive where datediff(hh, exported_dt, getdate())<1 and company=@v_instance) -- make sure the status of previous imported ara doesn't change, in case the status is turned back for an ara for some reason

end

go


	CREATE PROCEDURE dbo.sp_alterdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null,
		@version 	int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 			int
		declare @retval 		int
		declare @IsDbo 			int

		declare @UIDFound 		int
		declare @DiagId			int
		declare @ShouldChangeUID	int

		if(@diagramname is null)
		begin
			RAISERROR ('Invalid ARG', 16, 1)
			return -1
		end

		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;

		select @ShouldChangeUID = 0
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname

		if(@DiagId IS NULL or (@IsDbo = 0 and @theId <> @UIDFound))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		if(@IsDbo <> 0)
		begin
			if(@UIDFound is null or USER_NAME(@UIDFound) is null) -- invalid principal_id
			begin
				select @ShouldChangeUID = 1 ;
			end
		end

		-- update dds data
		update dbo.sysdiagrams set definition = @definition where diagram_id = @DiagId ;

		-- change owner
		if(@ShouldChangeUID = 1)
			update dbo.sysdiagrams set principal_id = @theId where diagram_id = @DiagId ;

		-- update dds version
		if(@version is not null)
			update dbo.sysdiagrams set version = @version where diagram_id = @DiagId ;

		return 0
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_alterdiagram'
go

grant execute on sp_alterdiagram to [public]
go


	CREATE PROCEDURE dbo.sp_creatediagram
	(
		@diagramname 	sysname,
		@owner_id		int	= null,
		@version 		int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId int
		declare @retval int
		declare @IsDbo	int
		declare @userName sysname
		if(@version is null or @diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end

		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		revert;

		if @owner_id is null
		begin
			select @owner_id = @theId;
		end
		else
		begin
			if @theId <> @owner_id
			begin
				if @IsDbo = 0
				begin
					RAISERROR (N'E_INVALIDARG', 16, 1);
					return -1
				end
				select @theId = @owner_id
			end
		end
		-- next 2 line only for test, will be removed after define name unique
		if EXISTS(select diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @diagramname)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end

		insert into dbo.sysdiagrams(name, principal_id , version, definition)
				VALUES(@diagramname, @theId, @version, @definition) ;

		select @retval = @@IDENTITY
		return @retval
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_creatediagram'
go

grant execute on sp_creatediagram to [public]
go


	CREATE PROCEDURE dbo.sp_dropdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int

		declare @UIDFound 		int
		declare @DiagId			int

		if(@diagramname is null)
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end

		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;

		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end

		delete from dbo.sysdiagrams where diagram_id = @DiagId;

		return 0;
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_dropdiagram'
go

grant execute on sp_dropdiagram to [public]
go


	CREATE PROCEDURE dbo.sp_helpdiagramdefinition
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 		int
		declare @IsDbo 		int
		declare @DiagId		int
		declare @UIDFound	int

		if(@diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end

		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;

		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname;
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId ))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		select version, definition FROM dbo.sysdiagrams where diagram_id = @DiagId ;
		return 0
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE',
     'sp_helpdiagramdefinition'
go

grant execute on sp_helpdiagramdefinition to [public]
go


	CREATE PROCEDURE dbo.sp_helpdiagrams
	(
		@diagramname sysname = NULL,
		@owner_id int = NULL
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		DECLARE @user sysname
		DECLARE @dboLogin bit
		EXECUTE AS CALLER;
			SET @user = USER_NAME();
			SET @dboLogin = CONVERT(bit,IS_MEMBER('db_owner'));
		REVERT;
		SELECT
			[Database] = DB_NAME(),
			[Name] = name,
			[ID] = diagram_id,
			[Owner] = USER_NAME(principal_id),
			[OwnerID] = principal_id
		FROM
			sysdiagrams
		WHERE
			(@dboLogin = 1 OR USER_NAME(principal_id) = @user) AND
			(@diagramname IS NULL OR name = @diagramname) AND
			(@owner_id IS NULL OR principal_id = @owner_id)
		ORDER BY
			4, 5, 1
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_helpdiagrams'
go

grant execute on sp_helpdiagrams to [public]
go


	CREATE PROCEDURE dbo.sp_renamediagram
	(
		@diagramname 		sysname,
		@owner_id		int	= null,
		@new_diagramname	sysname

	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int

		declare @UIDFound 		int
		declare @DiagId			int
		declare @DiagIdTarg		int
		declare @u_name			sysname
		if((@diagramname is null) or (@new_diagramname is null))
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end

		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;

		select @u_name = USER_NAME(@owner_id)

		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end

		-- if((@u_name is not null) and (@new_diagramname = @diagramname))	-- nothing will change
		--	return 0;

		if(@u_name is null)
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @new_diagramname
		else
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @owner_id and name = @new_diagramname

		if((@DiagIdTarg is not null) and  @DiagId <> @DiagIdTarg)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end

		if(@u_name is null)
			update dbo.sysdiagrams set [name] = @new_diagramname, principal_id = @theId where diagram_id = @DiagId
		else
			update dbo.sysdiagrams set [name] = @new_diagramname where diagram_id = @DiagId
		return 0
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_renamediagram'
go

grant execute on sp_renamediagram to [public]
go


	CREATE PROCEDURE dbo.sp_upgraddiagrams
	AS
	BEGIN
		IF OBJECT_ID(N'dbo.sysdiagrams') IS NOT NULL
			return 0;

		CREATE TABLE dbo.sysdiagrams
		(
			name sysname NOT NULL,
			principal_id int NOT NULL,	-- we may change it to varbinary(85)
			diagram_id int PRIMARY KEY IDENTITY,
			version int,

			definition varbinary(max)
			CONSTRAINT UK_principal_name UNIQUE
			(
				principal_id,
				name
			)
		);


		/* Add this if we need to have some form of extended properties for diagrams */
		/*
		IF OBJECT_ID(N'dbo.sysdiagram_properties') IS NULL
		BEGIN
			CREATE TABLE dbo.sysdiagram_properties
			(
				diagram_id int,
				name sysname,
				value varbinary(max) NOT NULL
			)
		END
		*/

		IF OBJECT_ID(N'dbo.dtproperties') IS NOT NULL
		begin
			insert into dbo.sysdiagrams
			(
				[name],
				[principal_id],
				[version],
				[definition]
			)
			select
				convert(sysname, dgnm.[uvalue]),
				DATABASE_PRINCIPAL_ID(N'dbo'),			-- will change to the sid of sa
				0,							-- zero for old format, dgdef.[version],
				dgdef.[lvalue]
			from dbo.[dtproperties] dgnm
				inner join dbo.[dtproperties] dggd on dggd.[property] = 'DtgSchemaGUID' and dggd.[objectid] = dgnm.[objectid]
				inner join dbo.[dtproperties] dgdef on dgdef.[property] = 'DtgSchemaDATA' and dgdef.[objectid] = dgnm.[objectid]

			where dgnm.[property] = 'DtgSchemaNAME' and dggd.[uvalue] like N'_EA3E6268-D998-11CE-9454-00AA00A3F36E_'
			return 2;
		end
		return 1;
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_upgraddiagrams'
go

