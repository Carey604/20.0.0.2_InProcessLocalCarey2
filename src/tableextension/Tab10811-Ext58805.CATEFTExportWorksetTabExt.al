tableextension 58805 "CAT EFT Export Workset TabExt" extends "EFT Export Workset" //10811
{
    // CAT.001 2020-06-23 CL - allow export to foreign currency EFT.
    //      - actually just want to change 10250 "Bulk Vendor Remit Reporting".CreateEFTRecord to assign genjnlline.amount to Amount (LCY)
    //        but there is no event there to hook into. So, had to change table 10810. Table 10811 is modified to match the new field.
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
}