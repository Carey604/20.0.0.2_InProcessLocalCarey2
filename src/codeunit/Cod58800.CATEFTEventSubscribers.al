codeunit 58800 "CAT EFT Event Subscribers"
// CAT.001 2020-01-06 CL - fix "CAT Vend. Bank Code" - the bank record was not read before using.
// CAT.002 2020-06-01 CL - add 50210; "CAT Vendor Bank City State"
// CAT.003 2020-06-17 CL - allow foreign currency EFT 
// CAT.004 2021-08-12 CL - report substitution. Includes the new report for CAT.003 to replace 10083 with 58800.
// CAT.005 2022-01-27 CL - Export SEPA. 
//      - When exporting direct debit file, the system should use "Bank Exprt/Import Setup"."Processing Codeunit ID". Currently, is
//        hardcoded to run CODEUNIT::"SEPA DD-Export File" instead.
//      - set custom field in "Payment Export Data" table to save the customer bank account systemid
{

    trigger OnRun()
    begin
    end;

    //>>CAT.003 
    [EventSubscriber(ObjectType::Table, database::"EFT Export", 'OnBeforeInsertEvent', '', false, false)]
    local procedure table10810_OnBeforeInsertEvent(VAR Rec: Record "EFT Export")
    //Wanted to change codeunit 10250 "Bulk Vendor Remit Reporting", procedure CreateEFTRecord to use Amount instead of Amount (LCY).
    //No event to hook into. So, added code here to get the genjnlline and assign amount.
    //For some reason, the OnBeforeInsert, OnInsert, and OnAfterInsert triggers never fire in the eft export table. Put the code here instead.
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if GenJnlLine.get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.") then begin
            Rec."CAT Original Amount (LCY)" := Rec."Amount (LCY)";
            Rec."CAT Original Amount" := GenJnlLine.Amount;
        end;
        //Bank.Get(Rec."Bank Account No.");
        //if Bank."CAT Skip EFT Curr. Code Check" then
        //    Rec."Amount (LCY)" := GenJnlLine.Amount;
    end;

    [EventSubscriber(ObjectType::Table, database::"Check Ledger Entry", 'OnBeforeInsertEvent', '', false, false)]
    local procedure table272_OnBeforeInsertEvent(VAR Rec: Record "Check Ledger Entry")
    //Wanted to change codeunit 10250 "Bulk Vendor Remit Reporting", procedure InsertIntoCheckLedger.
    //Needed to change Amount to use GenJnlLine.Amount instead of GenJournalLIne."Amount (LCY)" but no event to hook into.
    var
        Bank: Record "Bank Account";
        GenJnlLine: Record "Gen. Journal Line";
        RecRef: RecordRef;
        Amt: Decimal;
    begin
        if not RecRef.get(Rec."Record ID to Print") then
            exit;
        RecRef := Rec."Record ID to Print".GetRecord();
        RecRef.SetTable(GenJnlLine);
        GenJnlLine.find('=');
        if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment)
            and (GenJnlLine."Bank Payment Type" = GenJnlLine."Bank Payment Type"::"Electronic Payment")
            and (GenJnlLine."Currency Code" > '')
            and (GenJnlLine.Amount <> GenJnlLine."Amount (LCY)") then begin
            if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Bank Account" then begin
                Bank.Get(GenJnlLine."Account No.");
                Amt := -GenJnlLine."Amount";
            end else begin
                Bank.Get(GenJnlLine."Bal. Account No.");
                Amt := GenJnlLine."Amount";
            end;
            Rec.Amount := Amt;
        end;

    end;
    //<<CAT.003

    //>>CAT.004
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)]
    local procedure OnAfterSubstituteReport(ReportId: Integer; RunMode: Option; RequestPageXml: Text; RecordRef: RecordRef; var NewReportId: Integer);
    begin
        case ReportId of
            report::"Export Electronic Payments": //10083
                NewReportId := 58800;
        end;
    end;

    //<<CAT.004


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export EFT (RB)", 'OnBeforeACHRBHeaderModify', '', false, false)]
    local procedure cd10095ExportEFTRB_OnBeforeACHRBHeaderModify(VAR ACHRBHeader: Record "ACH RB Header"; BankAccount: Record "Bank Account")
    var

    begin
        ACHRBHeader."CAT File Creation Year" := DATE2DMY(Today, 3);
        ACHRBHeader."CAT File Creation Day (Julian)" := CATConvertToJulianDate(Today, 0);
        ACHRBHeader."CAT Bank Account No." := BankAccount."Bank Account No.";
        ACHRBHeader."CAT Bank Branch No." := BankAccount."Bank Branch No.";
        ACHRBHeader."CAT Bank Transit No." := BankAccount."Transit No.";
        ACHRBHeader."CAT Bank Code" := BankAccount."Bank Code";

        ACHRBHeader."CAT Bank Short Name" := BankAccount.CATBankShortName;
        ACHRBHeader."CAT Bank Long Name" := BankAccount.CATBankLongName;
        ACHRBHeader."CAT Destination Data Centre" := BankAccount.CATDestDataCentre;
        ACHRBHeader."CAT Originator ID" := BankAccount.CATOriginatorID;
        ACHRBHeader.CATFileCreationDateCYYDDD := '0' + FORMAT(CATConvertToJulianDate(Today, 1));
        ACHRBHeader.CATFileCreationDateDDMMYY := Format(Today, 0, '<Day,2><Month,2><Year,2>');
        ACHRBHeader.CATFileCreationDateMMDDYY := Format(Today, 0, '<Month,2><Day,2><Year,2>');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export EFT (RB)", 'OnBeforeACHRBDetailModify', '', false, false)]
    local procedure cd10095ExportEFTRB_OnBeforeACHRBDetailModify(VAR ACHRBDetail: Record "ACH RB Detail"; VAR TempEFTExportWorkset: Record "EFT Export Workset" temporary; BankAccNo: Code[20]; SettleDate: Date)
    var
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        //>>CAT.001
        VendorBankAccount.SETRANGE("Vendor No.", ACHRBDetail."Customer/Vendor Number");
        VendorBankAccount.SETRANGE("Use for Electronic Payments", TRUE);
        VendorBankAccount.FindFirst();
        //<<CAT.001
        BankAccount.get(BankAccNo);

        //Bank Account Info        
        ACHRBDetail."CAT Bank Account No." := DELCHR(BankAccount."Bank Account No.", '=', ' .,-');
        ACHRBDetail."CAT Bank Branch No." := DELCHR(BankAccount."Bank Branch No.", '=', ' .,-');
        ACHRBDetail."CAT Bank Transit No." := DELCHR(BankAccount."Transit No.", '=', ' .,-');
        ACHRBDetail."CAT Bank Code" := BankAccount."Bank Code";
        ACHRBDetail."CAT Bank Short Name" := BankAccount.CATBankShortName;
        ACHRBDetail."CAT Bank Long Name" := BankAccount.CATBankLongName;
        ACHRBDetail."CAT Destination Data Centre" := BankAccount.CATDestDataCentre;
        ACHRBDetail."CAT Originator ID" := BankAccount.CATOriginatorID;
        ACHRBDetail."CAT Input Qualifier" := BankAccount."Input Qualifier";
        ACHRBDetail."CAT File Creation Number" := BankAccount."Last E-Pay File Creation No.";

        //Vendor Bank Account Info        
        ACHRBDetail."CAT Vend. Bank Code" := VendorBankAccount."Bank Code";
        ACHRBDetail."CAT Vendor Branch No." := VendorBankAccount."Bank Branch No.";
        ACHRBDetail."CAT Vendor Transit No." := VendorBankAccount."Transit No.";
        ACHRBDetail."CAT Vendor Bank Address" := VendorBankAccount.Address;
        ACHRBDetail."CAT Vendor Bank Address 2" := VendorBankAccount."Address 2";
        ACHRBDetail."CAT Vendor Bank City" := VendorBankAccount.City;
        ACHRBDetail."CAT Vendor Bank State" := VendorBankAccount.County;
        ACHRBDetail."CAT Vendor Bank Post Code" := VendorBankAccount."Post Code";
        ACHRBDetail."CAT Vendor Bank Country/Region" := VendorBankAccount."Country/Region Code";
        ACHRBDetail."CAT Vendor Bank City State" := DelChr(VendorBankAccount.City, '<>', ' ') + ' ' + DelChr(VendorBankAccount.County, '<>', ' '); //++CAT.002
        ACHRBDetail."CAT Vendor Bank ACH Rout. No." := VendorBankAccount."CAT ACH Routing No.";

        //File Creation Info        
        ACHRBDetail."CAT File Creation Year" := DATE2DMY(Today, 3);
        ACHRBDetail."CAT File Creation Day (Julian)" := CATConvertToJulianDate(Today, 0);
        ACHRBDetail."CAT Payment Date Year" := DATE2DMY(SettleDate, 3);
        ACHRBDetail."CAT Payment Date Day (Julian)" := CATConvertToJulianDate(TempEFTExportWorkset."Settle Date", 0);
        ACHRBDetail.CATFileCreationDateCYYDDD := '0' + FORMAT(CATConvertToJulianDate(Today, 1));
        IF TempEFTExportWorkset."Settle Date" <> 0D then
            ACHRBDetail.CATPaymentDateCYYDDD := '0' + FORMAT(CATConvertToJulianDate(TempEFTExportWorkset."Settle Date", 1))
        else
            ACHRBDetail.CATPaymentDateCYYDDD := '0' + FORMAT(CATConvertToJulianDate(Today, 1));
        ACHRBDetail.CATPaymentDateDDMMYY := Format(TempEFTExportWorkset."Settle Date", 0, '<Day,2><Month,2><Year,2>');
        ACHRBDetail.CATPaymentDateMMDDYY := Format(TempEFTExportWorkset."Settle Date", 0, '<Month,2><Day,2><Year,2>');
        ACHRBDetail.CATFileCreationDateDDMMYY := Format(Today, 0, '<Day,2><Month,2><Year,2>');
        ACHRBDetail.CATFileCreationDateMMDDYY := Format(Today, 0, '<Month,2><Day,2><Year,2>');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export EFT (RB)", 'OnBeforeACHRBFooterModify', '', false, false)]
    local procedure cd10095ExportEFTRB_OnBeforeACHRBFooterModify(VAR ACHRBFooter: Record "ACH RB Footer"; BankAccNo: Code[20])
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.get(BankAccNo);
        ACHRBFooter."CAT File Creation Year" := DATE2DMY(Today, 3);
        ACHRBFooter."CAT File Creation Day (Julian)" := CATConvertToJulianDate(Today, 0);
        ACHRBFooter."CAT Bank Account No." := DELCHR(BankAccount."Bank Account No.", '=', ' .,-');
        ACHRBFooter."CAT Bank Branch No." := DELCHR(BankAccount."Bank Branch No.", '=', ' .,-');
        ACHRBFooter."CAT Bank Transit No." := DELCHR(BankAccount."Transit No.", '=', ' .,-');
        ACHRBFooter."CAT Bank Code" := BankAccount."Bank Code";
        ACHRBFooter."CAT Input Qualifier" := BankAccount."Input Qualifier";
        ACHRBFooter."CAT File Creation Number" := BankAccount."Last E-Pay File Creation No.";
        ACHRBFooter."CAT Bank Short Name" := BankAccount.CATBankShortName;
        ACHRBFooter."CAT Bank Long Name" := BankAccount.CATBankLongName;
        ACHRBFooter."CAT Destination Data Centre" := BankAccount.CATDestDataCentre;
        ACHRBFooter."CAT Originator ID" := BankAccount.CATOriginatorID;
        ACHRBFooter.CATFileCreationDateCYYDDD := '0' + FORMAT(CATConvertToJulianDate(Today, 1));
        BankAccount."Last E-Pay File Creation No." -= BankAccount.CATFileCreationDecrement;
        BankAccount.MODIFY;
    end;


    local procedure CATConvertToJulianDate(InputDate: Date; Type: Option Normal,YYDDD) JulianDate: Integer
    var
        YearInteger: Integer;
    begin
        IF InputDate <> 0D THEN BEGIN
            CASE Type OF
                Type::Normal:
                    BEGIN
                        EXIT(InputDate - DMY2DATE(1, 1, DATE2DMY(InputDate, 3)));
                    END;
                Type::YYDDD:
                    BEGIN
                        EVALUATE(YearInteger, COPYSTR(FORMAT(DATE2DMY(InputDate, 3)), 3, 2));
                        EXIT((YearInteger * 1000) + (InputDate - DMY2DATE(1, 1, DATE2DMY(InputDate, 3))) + 1);
                    END;
            END;
        END;
    end;

    //>>CAT.005
    [EventSubscriber(ObjectType::Table, Database::"Direct Debit Collection Entry", 'OnBeforeExportSEPA', '', false, false)]
    local procedure tab1208_OnBeforeExportSEPA(var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var IsHandled: Boolean);
    var
        DirectDebitCollection: Record "Direct Debit Collection";
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if DirectDebitCollection.Get(DirectDebitCollectionEntry."Direct Debit Collection No.") then
            if BankAccount.Get(DirectDebitCollection."To Bank Account No.") then
                if BankExportImportSetup.Get(BankAccount."SEPA Direct Debit Exp. Format") then
                    if BankExportImportSetup."Processing Codeunit ID" > 0 then begin
                        CODEUNIT.Run(BankExportImportSetup."Processing Codeunit ID", DirectDebitCollectionEntry);
                        IsHandled := true;
                    end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Export Data", 'OnAfterSetCustomerAsRecipient', '', false, false)]
    local procedure OnAfterSetCustomerAsRecipient(var PaymentExportData: Record "Payment Export Data"; var Customer: Record Customer; var CustomerBankAccount: Record "Customer Bank Account");
    begin
        PaymentExportData."CAT Cust. Bank Acc. SystemId" := CustomerBankAccount.SystemId;
    end;
    //<<CAT.005

}