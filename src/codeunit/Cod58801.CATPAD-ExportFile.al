codeunit 58801 "CAT Canada AFT PAD-Export File"
{
    // CAT.001 2022-01-05 CL - copied from 1230 "SEPA DD-Export File"
    //      - Change export file name extension 
    // CAT.002 2022-06-09 CL - for ACH PPD filename. Add prefix to filename.
    TableNo = "Direct Debit Collection Entry";

    trigger OnRun()
    var
        DirectDebitCollection: Record "Direct Debit Collection";
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
        BankAccount: Record "Bank Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        DirectDebitCollectionEntry.Copy(Rec);
        GetDirectDebitCollection(Rec, DirectDebitCollection);
        DirectDebitCollection.TestField("To Bank Account No.");
        BankAccount.Get(DirectDebitCollection."To Bank Account No.");
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."SEPA Export w/o Bank Acc. Data" then
            BankAccount.TestField(IBAN)
        else
            if (BankAccount."Bank Account No." = '') or (BankAccount."Bank Branch No." = '') then
                if BankAccount.IBAN = '' then
                    Error(ExportWithoutIBANErr, BankAccount.TableCaption(), BankAccount."No.");

        DirectDebitCollection.LockTable();
        DirectDebitCollection.DeletePaymentFileErrors;
        Commit();
        //--CAT.002if not Export(Rec, BankAccount.GetDDExportXMLPortID, DirectDebitCollection.Identifier) then
        if not Export(Rec, BankAccount.GetDDExportXMLPortID, StrSubstNo('%1%2', BankAccount."CAT ACH PAD Filename Prefix", DirectDebitCollection.Identifier)) then //++CAT.002
            Error('');

        DirectDebitCollectionEntry.SetRange("Direct Debit Collection No.", DirectDebitCollection."No.");
        DirectDebitCollectionEntry.ModifyAll(Status, DirectDebitCollectionEntry.Status::"File Created");
        DirectDebitCollection.Status := DirectDebitCollection.Status::"File Created";
        DirectDebitCollection.Modify();
    end;

    var
        ExportToServerFile: Boolean;
        ExportWithoutIBANErr: Label 'Either the Bank Account No. and Bank Branch No. fields or the IBAN field must be filled in for %1 %2.', Comment = '%1= table name, %2=key field value. Example: Either the Bank Account No. and Bank Branch No. fields or the IBAN field must be filled in for Bank Account WWB-OPERATING.';

    local procedure Export(var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; XMLPortID: Integer; FileName: Text) Result: Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        OutStr: OutStream;
        IsHandled: Boolean;
    begin
        TempBlob.CreateOutStream(OutStr);
        XMLPORT.Export(XMLPortID, OutStr, DirectDebitCollectionEntry);

        IsHandled := false;
        OnExportOnAfterXMLPortExport(TempBlob, Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(FileManagement.BLOBExportWithEncoding(TempBlob, StrSubstNo('%1.txt', FileName), not ExportToServerFile, TextEncoding::Windows) <> ''); //++CAT.001- if text encoding UTF8, then we get byte order mark (EF BB BF at start of file)
        //--CAT.001exit(FileManagement.BLOBExport(TempBlob, StrSubstNo('%1.XML', FileName), not ExportToServerFile) <> '');
    end;

    local procedure GetDirectDebitCollection(var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var DirectDebitCollection: Record "Direct Debit Collection")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetDirectDebitCollection(DirectDebitCollectionEntry, DirectDebitCollection, IsHandled);
        if IsHandled then
            exit;

        DirectDebitCollectionEntry.TestField("Direct Debit Collection No.");
        DirectDebitCollection.Get(DirectDebitCollectionEntry."Direct Debit Collection No.");
    end;

    procedure EnableExportToServerFile()
    begin
        ExportToServerFile := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDirectDebitCollection(var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var DirectDebitCollection: Record "Direct Debit Collection"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExportOnAfterXMLPortExport(var TempBlob: Codeunit "Temp Blob"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}
