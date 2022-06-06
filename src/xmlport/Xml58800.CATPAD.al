xmlport 58800 "CAT Canada BMO AFT PAD 1464"
{
    // CAT.001 2022-01-20 CL - copied from xmlport 1010 
    //      - new xmlport to meet PAD 1464: Header, Detail, Trailer. 1464 bytes flat file.

    Caption = 'Canada BMO AFT PAD 1464';
    Direction = Export;
    //TextEncoding = UTF8;
    TextEncoding = WINDOWS; //++CAT.001 - if text encoding UTF8, then we get byte order mark (EF BB BF at start of file)
    FormatEvaluate = Legacy;
    UseRequestPage = false;
    //Format = FixedText;
    //RecordSeparator = '<CR>';
    //TableSeparator = '<CR>';
    Format = VariableText;
    FieldDelimiter = '<None>';
    RecordSeparator = '<None>';
    TableSeparator = '<None>';

    schema
    {
        textelement(Root)
        {
            tableelement("Direct Debit Collection Entry"; "Direct Debit Collection Entry")
            {
                XmlName = 'Document';
                //UseTemporary = true; //this must not be true because on export of txt file it never finds a temporary record.
                trigger OnAfterGetRecord()
                begin
                    currXMLport.Break();
                end;
            }
            tableelement(RecordALoop; Integer) //header record
            {
                XmlName = 'RecAloop';

                textelement(RecordA)
                {
                    trigger OnBeforePassVariable()
                    begin
                        RecordA := RecordATxt + CR;
                    end;

                }

                trigger OnPreXmlItem() //RecordALoop
                begin
                    RecordALoop.SetRange(Number, 1, 1);
                end;

                trigger OnAfterGetRecord()
                begin
                    LogicalRecordCount += 1;
                    RecordATxt := '';
                    AddToPrnString(RecordATxt, 'A', 1, 1, Justification::Left, ' ');
                    AddNumToPrnString(RecordATxt, LogicalRecordCount, 2, 9);
                    AddToPrnString(RecordATxt, OriginatorTxt, 11, 10, Justification::Left, ' ');
                    AddToPrnString(RecordATxt, FileCreationNoTxt, 21, 4, Justification::Right, '0');
                    AddNumToPrnString(RecordATxt, JulianDate(FileDate), 25, 6);
                    AddToPrnString(RecordATxt, DestinationDataCenterTxt, 31, 5, Justification::Right, '0');
                    AddToPrnString(RecordATxt, ' ', 36, 20, Justification::Left, ' ');
                    AddToPrnString(RecordATxt, CurrCodeTxt, 56, 3, Justification::Left, ' ');
                    AddToPrnString(RecordATxt, ' ', 59, 1406, Justification::Left, ' '); //filler 1406 blanks
                end;
            }
            // tableelement(companyinformation; "Company Information")
            // {
            //     //XmlName = 'CstmrDrctDbtInitn';
            //     textelement(GrpHdr)
            //     {
            //     }
            tableelement(TempPaymentExportDataGroupLoop; Integer)
            {
                XmlName = 'PmtInf';

                tableelement(TempPaymentExportDataLoop; Integer)
                {
                    XmlName = 'DrctDbtTxInf';
                    textelement(RecordD) //detail record
                    {
                        trigger OnBeforePassVariable()
                        var
                        begin
                            RecordD := RecordDTxt + CR;
                        end;
                    }

                    trigger OnPreXmlItem() //TempPaymentExportDataLoop
                    var
                    begin
                        //this has to match comparisons in IsNewGroup
                        TempPaymentExportData.reset;
                        TempPaymentExportData.SetRange("Sender Bank BIC", TempPaymentExportDataGroup."Sender Bank BIC");
                        // TempPaymentExportData.SetRange("SEPA Instruction Priority Text", TempPaymentExportDataGroup."SEPA Instruction Priority Text");
                        // TempPaymentExportData.SetRange("Transfer Date", TempPaymentExportDataGroup."Transfer Date");
                        // TempPaymentExportData.SetRange("SEPA Direct Debit Seq. Text", TempPaymentExportDataGroup."SEPA Direct Debit Seq. Text");
                        // TempPaymentExportData.SetRange("SEPA Partner Type Text", TempPaymentExportDataGroup."SEPA Partner Type Text");
                        // TempPaymentExportData.SetRange("SEPA Batch Booking", TempPaymentExportDataGroup."SEPA Batch Booking");
                        // TempPaymentExportData.SetRange("SEPA Charge Bearer Text", TempPaymentExportDataGroup."SEPA Charge Bearer Text");

                        TempPaymentExportDataLoop.SetRange(Number, 1, TempPaymentExportData.Count);
                    end;

                    trigger OnAfterGetRecord() //TempPaymentExportDataLoop
                    var
                        CustomerBankAccount: Record "Customer Bank Account";
                    begin
                        if TempPaymentExportDataLoop.Number = 1 then
                            TempPaymentExportData.FindFirst()
                        else
                            TempPaymentExportData.Next();

                        CustomerBankAccount.GetBySystemId(TempPaymentExportData."CAT Cust. Bank Acc. SystemId");
                        CustomerBankAccount.TestField("Bank Code");
                        CustomerBankAccount.testfield("Bank Branch No.");
                        CustomerBankAccount.testfield("Bank Account No.");

                        LogicalRecordCount += 1;
                        DetailRecordCount += 1;

                        RecordDTxt := '';
                        AddToPrnString(RecordDTxt, 'D', 1, 1, Justification::Left, ' ');
                        AddNumToPrnString(RecordDTxt, LogicalRecordCount, 2, 9);
                        AddToPrnString(RecordDTxt, OriginatorTxt, 11, 10, Justification::Left, ' ');
                        AddToPrnString(RecordDTxt, FileCreationNoTxt, 21, 4, Justification::Right, '0');
                        AddToPrnString(RecordDTxt, '450', 25, 3, Justification::Right, ' ');
                        AddAmtToPrnString(RecordDTxt, TempPaymentExportData.Amount, 28, 10);
                        AddNumToPrnString(RecordDTxt, JulianDate(TempPaymentExportData."Transfer Date"), 38, 6);
                        // next 3 fields make up the institutional id no.: 0tttbbbbb t=institution no=bankcode, b=branch routing no.=bank branch no.
                        AddToPrnString(RecordDTxt, '0', 44, 1, Justification::Left, '0');
                        AddToPrnString(RecordDTxt, CopyStr(CustomerBankAccount."Bank Code", 1, 3), 45, 3, Justification::Left, '0');
                        AddToPrnString(RecordDTxt, CopyStr(CustomerBankAccount."Bank Branch No.", 1, 5), 48, 5, Justification::Left, '0');
                        AddToPrnString(RecordDTxt, CopyStr(CustomerBankAccount."Bank Account No.", 1, 12), 53, 12, Justification::Left, ' ');
                        AddToPrnString(RecordDTxt, '0', 65, 25, Justification::Left, '0');
                        AddToPrnString(RecordDTxt, CopyStr(BankAccount.CATBankShortName, 1, 15), 90, 15, Justification::Left, ' ');
                        AddToPrnString(RecordDTxt, CopyStr(CustomerBankAccount.Name, 1, 30), 105, 30, Justification::Left, ' ');
                        AddToPrnString(RecordDTxt, CopyStr(BankAccount.CATBankLongName, 1, 30), 135, 30, Justification::Left, ' ');
                        AddToPrnString(RecordDTxt, ' ', 165, 10, Justification::Left, ' ');
                        AddToPrnString(RecordDTxt, CopyStr(TempPaymentExportData."Document No.", 1, 15), 175, 15, Justification::Left, ' ');
                        AddToPrnString(RecordDTxt, ' ', 190, 4, Justification::Left, ' ');
                        // next 3 fields make up the institutional id no. for a return: 0tttbbbbb t=institution no=bankcode, b=branch routing no.=bank branch no.
                        AddToPrnString(RecordDTxt, '0', 194, 1, Justification::Left, '0');
                        AddToPrnString(RecordDTxt, CopyStr(CustomerBankAccount."Bank Code", 1, 3), 195, 3, Justification::Left, '0');
                        AddToPrnString(RecordDTxt, CopyStr(CustomerBankAccount."Bank Branch No.", 1, 5), 198, 5, Justification::Left, '0');
                        AddToPrnString(RecordDTxt, CopyStr(CustomerBankAccount."Bank Account No.", 1, 12), 203, 12, Justification::Left, ' ');
                        AddNumToPrnString(RecordDTxt, 0, 215, 15);
                        AddNumToPrnString(RecordDTxt, 0, 230, 9);
                        AddNumToPrnString(RecordDTxt, 0, 239, 9);
                        AddToPrnString(RecordDTxt, ' ', 248, 3, Justification::Left, ' ');
                        AddToPrnString(RecordDTxt, ' ', 251, 3, Justification::Left, ' ');
                        AddNumToPrnString(RecordDTxt, 0, 254, 11);
                        AddToPrnString(RecordDTxt, ' ', 265, 1200, Justification::Left, ' ');
                    end;
                }

                trigger OnPreXmlItem() //TempPaymentExportDataGroupLoop
                var
                begin
                    TempPaymentExportDataGroup.reset;
                    TempPaymentExportDataGroupLoop.SetRange(Number, 1, TempPaymentExportDataGroup.Count);
                end;

                trigger OnAfterGetRecord() //TempPaymentExportDataGroupLoop
                var
                begin
                    if TempPaymentExportDataGroupLoop.Number = 1 then
                        TempPaymentExportDataGroup.FindFirst()
                    else
                        TempPaymentExportDataGroup.Next();
                end;
            }

            tableelement(RecordZLoop; Integer)
            {
                textelement(RecordZ) //trailer record
                {
                    trigger OnBeforePassVariable()
                    begin
                        RecordZ := RecordZTxt + CR;
                    end;
                }


                trigger OnPreXmlItem()
                begin
                    RecordZLoop.SetRange(Number, 1, 1);
                end;

                trigger OnAfterGetRecord()
                var
                begin
                    LogicalRecordCount += 1;
                    RecordZTxt := '';
                    AddToPrnString(RecordZTxt, 'Z', 1, 1, Justification::Left, ' ');
                    AddNumToPrnString(RecordZTxt, LogicalRecordCount, 2, 9);
                    AddToPrnString(RecordZTxt, OriginatorTxt, 11, 10, Justification::Left, ' ');
                    AddToPrnString(RecordZTxt, FileCreationNoTxt, 21, 4, Justification::Right, '0');
                    AddAmtToPrnString(RecordZTxt, DControlTotal, 25, 14);
                    AddNumToPrnString(RecordZTxt, DCount, 39, 8);
                    AddAmtToPrnString(RecordZTxt, CControlTotal, 47, 14);
                    AddNumToPrnString(RecordZTxt, CCount, 61, 8);
                    AddToPrnString(RecordZTxt, ' ', 69, 1396, Justification::Left, ' '); //filler 1396 blanks
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPreXmlPort()
    begin
        CR[1] := 13;
        FileDate := Today;
        InitData;
    end;

    var
        NoDataToExportErr: Label 'There is no data to export. Make sure the %1 field is not set to %2 or %3.', Comment = '%1=Field;%2=Value;%3=Value';

    local procedure InitData()
    var
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
        DirectDebitCollection: Record "Direct Debit Collection";
        GLSetup: Record "General Ledger Setup";
        SEPADDFillExportBuffer: Codeunit "SEPA DD-Fill Export Buffer";
        PaymentGroupNo: Integer;
        i: Integer;
        DestDataCenterErr: label '%1 cannot be %2 in %3 %4. Only numerals are allowed when using preauthorized debits in Canada.';
        CurrCodeErr: label '%1 cannot be %2 in %3 %4. Only CAD or USD are allowed when using preauthorized debits in Canada.';

    begin
        SEPADDFillExportBuffer.FillExportBuffer("Direct Debit Collection Entry", TempPaymentExportData);
        //PaymentMethodDD := 'DD';
        //ServiceLevelCodeSEPA := 'SEPA';
        //SchmeNmPrtry := 'SEPA';
        //NoOfTransfers := Format(PaymentExportData.Count);
        //MessageID := PaymentExportData."Message ID";
        //CreatedDateTime := Format(CurrentDateTime, 19, 9);
        TempPaymentExportData.CalcSums(Amount);
        DControlTotal := TempPaymentExportData.Amount;
        DCount := TempPaymentExportData.Count;
        CControlTotal := 0;
        CCount := 0;

        TempPaymentExportData.SetCurrentKey(
          "Sender Bank BIC", "SEPA Instruction Priority Text", "Transfer Date",
          "SEPA Direct Debit Seq. Text", "SEPA Partner Type Text", "SEPA Batch Booking", "SEPA Charge Bearer Text");

        if not TempPaymentExportData.FindSet then
            Error(NoDataToExportErr, DirectDebitCollectionEntry.FieldCaption(Status),
              DirectDebitCollectionEntry.Status::Rejected, DirectDebitCollection.Status::Canceled);

        InitPmtGroup;
        repeat
            if IsNewGroup then begin
                InsertPmtGroup(PaymentGroupNo);
                InitPmtGroup;
            end;
            TempPaymentExportDataGroup."Line No." += 1;
            TempPaymentExportDataGroup.Amount += TempPaymentExportData.Amount;
        until TempPaymentExportData.Next() = 0;
        InsertPmtGroup(PaymentGroupNo);

        //file creation no - use rightmost 4 chars of message id. That no. was generated from Bank."Direct debit msg. nos."
        FileCreationNoTxt := GetTrailing4Numerals(TempPaymentExportDataGroup."Message ID");

        BankAccount.Get(TempPaymentExportData."Sender Bank Account Code");
        BankAccount.TestField(CATOriginatorID);
        OriginatorTxt := BankAccount.CATOriginatorID;
        BankAccount.TestField(CATDestDataCentre);
        DestinationDataCenterTxt := copystr(delchr(BankAccount.CATDestDataCentre, '<>', ' '), 1, 5);
        if not Evaluate(i, DestinationDataCenterTxt) then
            error(DestDataCenterErr,
                BankAccount.FieldCaption(CATDestDataCentre),
                BankAccount.CATDestDataCentre,
                BankAccount.TableCaption,
                BankAccount."No.");

        if BankAccount."Currency Code" > '' then begin
            //        CurrCodeErr: label  '%1 cannot be %2 in %3 %4. Only CAD or USD are allowed when using preauthorized debits in Canada.';
            if not ((BankAccount."Currency Code" = 'CAD') or (BankAccount."Currency Code" = 'USD')) then
                error(CurrCodeErr,
                    BankAccount.FieldCaption("Currency Code"),
                    BankAccount."Currency Code",
                    BankAccount.TableCaption,
                    BankAccount."No.");
            CurrCodeTxt := copystr(BankAccount."Currency Code", 1, 3);
        end else begin
            GLSetup.Get();
            if (GLSetup.GetCurrencyCode('CAD') = '') then //LCY = CAD 
                CurrCodeTxt := '' //can be blank for CAD
            else
                if (GLSetup.GetCurrencyCode('USD') = '') then //LCY = USD
                    CurrCodeTxt := 'USD'
                else //in all other cases, if bank currency is blank, then if lcy code isn't CAD or USD then it is using a non-allowed currency
                    error(CurrCodeErr,
                        BankAccount.FieldCaption("Currency Code"),
                        BankAccount."Currency Code",
                        BankAccount.TableCaption,
                        BankAccount."No.");
        end;
    end;

    local procedure GetTrailing4Numerals(TextIn: Text): Text[4];
    var
        ResultTxt: Text;
        CharTxt: Text;
        i: Integer;
        j: integer;
    begin
        TextIn := delchr(TextIn, '<>', ' ');
        for i := StrLen(TextIn) downto 1 do begin
            j := j + 1;
            CharTxt := copystr(TextIn, i, 1);
            if (CharTxt >= '0') and (CharTxt <= '9') then begin
                ResultTxt := CharTxt + ResultTxt;
            end else
                exit(copystr(ResultTxt, 1, 4));
            if j = 4 then
                exit(copystr(ResultTxt, 1, 4));
        end;
        exit(copystr(ResultTxt, 1, 4));
    end;

    local procedure IsNewGroup(): Boolean
    begin
        exit((TempPaymentExportData."Sender Bank BIC" <> TempPaymentExportDataGroup."Sender Bank BIC"));
        // exit(
        //   (TempPaymentExportData."Sender Bank BIC" <> TempPaymentExportDataGroup."Sender Bank BIC") or
        //   (TempPaymentExportData."SEPA Instruction Priority Text" <> TempPaymentExportDataGroup."SEPA Instruction Priority Text") or
        //   (TempPaymentExportData."Transfer Date" <> TempPaymentExportDataGroup."Transfer Date") or
        //   (TempPaymentExportData."SEPA Direct Debit Seq. Text" <> TempPaymentExportDataGroup."SEPA Direct Debit Seq. Text") or
        //   (TempPaymentExportData."SEPA Partner Type Text" <> TempPaymentExportDataGroup."SEPA Partner Type Text") or
        //   (TempPaymentExportData."SEPA Batch Booking" <> TempPaymentExportDataGroup."SEPA Batch Booking") or
        //   (TempPaymentExportData."SEPA Charge Bearer Text" <> TempPaymentExportDataGroup."SEPA Charge Bearer Text"));
    end;

    local procedure InitPmtGroup()
    begin
        TempPaymentExportDataGroup := TempPaymentExportData;
        TempPaymentExportDataGroup."Line No." := 0; // used for counting transactions within group
        TempPaymentExportDataGroup.Amount := 0; // used for summarizing transactions within group
    end;

    local procedure InsertPmtGroup(var PaymentGroupNo: Integer)
    begin
        PaymentGroupNo += 1;
        TempPaymentExportDataGroup."Entry No." := PaymentGroupNo;
        TempPaymentExportDataGroup."Payment Information ID" :=
          CopyStr(
            StrSubstNo('%1/%2', TempPaymentExportData."Message ID", PaymentGroupNo),
            1, MaxStrLen(TempPaymentExportDataGroup."Payment Information ID"));
        TempPaymentExportDataGroup.Insert();
    end;

    local procedure AddNumToPrnString(var PrnString: Text; Number: Integer; StartPos: Integer; Length: Integer)
    //copied from cod100091 and modified
    var
        TmpString: Text;
    begin
        TmpString := DelChr(Format(Number), '=', '.,-');
        AddToPrnString(PrnString, TmpString, StartPos, Length, Justification::Right, '0');
    end;

    local procedure AddAmtToPrnString(var PrnString: Text; Amount: Decimal; StartPos: Integer; Length: Integer)
    //copied from cod100091 and modified
    var
        TmpString: Text;
        I: Integer;
    begin
        TmpString := Format(Amount);
        I := StrPos(TmpString, '.');
        case true of
            I = 0:
                TmpString := TmpString + '.00';
            I = StrLen(TmpString) - 1:
                TmpString := TmpString + '0';
        end;
        TmpString := DelChr(TmpString, '=', '.,-');
        AddToPrnString(PrnString, TmpString, StartPos, Length, Justification::Right, '0');
    end;


    local procedure AddToPrnString(var PrnString: Text; SubString: Text; StartPos: Integer; Length: Integer; Justification: Option Left,Right; Filler: Text[1])
    //copied from cod10091 and modified
    var
        I: Integer;
        SubStrLen: Integer;
    begin
        SubString := UpperCase(DelChr(SubString, '<>', ' '));
        SubStrLen := StrLen(SubString);

        if SubStrLen > Length then begin
            SubString := CopyStr(SubString, 1, Length);
            SubStrLen := Length;
        end;

        if Justification = Justification::Right then
            for I := 1 to (Length - SubStrLen) do
                SubString := Filler + SubString
        else
            for I := SubStrLen + 1 to Length do
                SubString := SubString + Filler;

        if StrLen(PrnString) >= StartPos then
            if StartPos > 1 then
                PrnString := CopyStr(PrnString, 1, StartPos - 1) + SubString + CopyStr(PrnString, StartPos)
            else
                PrnString := SubString + PrnString
        else begin
            for I := StrLen(PrnString) + 1 to StartPos - 1 do
                PrnString := PrnString + ' ';
            PrnString := PrnString + SubString;
        end;
    end;

    procedure JulianDate(NormalDate: Date): Integer
    //copied from cod10095
    var
        Year: Integer;
        Days: Integer;
    begin
        Year := Date2DMY(NormalDate, 3);
        Days := (NormalDate - DMY2Date(1, 1, Year)) + 1;
        exit((Year mod 100) * 1000 + Days);
    end;


    var
        TempPaymentExportDataGroup: record "Payment Export Data" temporary;
        TempPaymentExportData: record "Payment Export Data" temporary;
        BankAccount: Record "Bank Account";

        DetailRecordCount: Integer;
        Justification: Option Left,Right;

        RecordATxt: Text;
        RecordDTxt: Text;
        RecordZTxt: Text;
        CR: Text[1];
        DCount: Integer;
        DControlTotal: Decimal;
        CCount: Integer;
        CControlTotal: Decimal;
        LogicalRecordCount: Integer;
        FileDate: Date;
        FileCreationNoTxt: Text;
        OriginatorTxt: Text[10];
        DestinationDataCenterTxt: Text[5];
        CurrCodeTxt: Text[3];


}