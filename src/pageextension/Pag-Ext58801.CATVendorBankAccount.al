pageextension 58801 "CAT Vendor Bank Account" extends "Vendor Bank Account Card"
{
    layout
    {
        addafter("Transit No.")
        {
            field("CAT ACH Routing No."; "CAT ACH Routing No.")
            {
                Caption = 'ACH Routing No.';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
    //myInt: Integer;
}