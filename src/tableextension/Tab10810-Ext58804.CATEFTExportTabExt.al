tableextension 58804 "CAT EFT Export TabExt" extends "EFT Export" //10810
{
    // CAT.001 2020-06-23 CL - allow export to foreign currency EFT.
    //      - actually just want to change 10250 "Bulk Vendor Remit Reporting".CreateEFTRecord to assign genjnlline.amount to Amount (LCY)
    //        but there is no event there to hook into
    fields
    {
        field(50800; "CAT Original Amount (LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Original Amount (LCY)';
        }
        field(50801; "CAT Original Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Original Amount';
        }
    }

    //This trigger never fires so put into codeunit58800 event subscriber instead
    // trigger OnBeforeInsert()
    // var
    //     Bank: Record "Bank Account";
    //     GenJnlLine: Record "Gen. Journal Line";
    // begin
    //     message('in here');
    //     error('in here');
    //     GenJnlLine.get("Journal Template Name", "Journal Batch Name", "Line No.");
    //     "CAT Original Amount (LCY)" := "Amount (LCY)";
    //     "CAT Original Amount" := GenJnlLine.Amount;
    //     Bank.Get("Bank Account No.");
    //     if Bank."CAT Skip EFT Curr. Code Check" then
    //         "Amount (LCY)" := GenJnlLine.Amount;
    // end;
}