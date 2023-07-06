xmlport 58801 "CAT Canada AFT ACH PAD"
{
    // CAT.001 2022-01-20 CL - copied from xmlport 1010 
    //      - new xmlport to meet NACHA 94 chars. See https://achdevguide.nacha.org/ach-file-details
    // CAT.002 2022-07-20 CL - add LF

    Caption = 'Canada AFT ACH PAD';
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
            tableelement(RecordALoop; Integer) //header record A
            {
                XmlName = 'RecALoop';
                textelement(RecordA)
                {
                    trigger OnBeforePassVariable()
                    begin
                        RecordA := RecordATxt + CR + LF; //++CAT.002 added + LF
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
                    AddToPrnString(RecordATxt, '1', 1, 1, Justification::Left, ' ');                                                            // Record Type: always 1
                    AddToPrnString(RecordATxt, '01', 2, 2, Justification::Left, ' ');                                                           // Priority Code: always 01
                    AddToPrnString(RecordATxt, BankAccount."CAT ACH PAD Immediate Dest.", 4, 10, Justification::Right, ' ');                    // Immediate Destination: The nine-digit routing number of the institution receiving the ACH file for processing, preceded by a blank. Typically, this is your bank’s routing and transit number.
                    AddToPrnString(RecordATxt, BankAccount."CAT ACH PAD Immediate Origin", 14, 10, Justification::Right, ' ');                  // Immediate Origin: The nine-digit routing transit number of the institution sending (originating) the ACH file, preceded by a blank. (Often your ODFI will have you insert your company ID in this field.)
                    AddToPrnString(RecordATxt, format(DT2Date(FileDateTime), 6, '<Year><Month,2><Day,2>'), 24, 6, Justification::Left, ' ');    // File Creation Date: YYMMDD
                    AddToPrnString(RecordATxt, format(DT2Time(FileDateTime), 6, '<Hours24,2><Minutes,2>'), 30, 4, Justification::Left, ' ');    // File Creation Time: HHMM
                    AddToPrnString(RecordATxt, BankAccount."CAT Last ACH PAD File ID Mod.", 34, 1, Justification::Left, ' ');                   // File ID Modifier - each processing day increment A-Z, 0-9
                    AddToPrnString(RecordATxt, '094', 35, 3, Justification::Left, '0');                                                         // Record Size: always 094
                    AddToPrnString(RecordATxt, '10', 38, 2, Justification::Right, '0');                                                         // Blocking factor: always 10
                    AddToPrnString(RecordATxt, '1', 40, 1, Justification::Left, '0');                                                           // Format Code: always 1
                    AddToPrnString(RecordATxt, BankAccount."CAT ACH PAD Immed. Dest. Name", 41, 23, Justification::Left, ' ');                  // Immediate Destination Name 
                    AddToPrnString(RecordATxt, BankAccount."CAT ACH PAD Immed. Origin Name", 64, 23, Justification::Left, ' ');                 // Immediate Origin Name
                    AddToPrnString(RecordATxt, ' ', 87, 8, Justification::Left, ' ');                                                           // Reference Code: always blank 8
                end;
            }
            tableelement(RecordBLoop; Integer) //header record
            {
                XmlName = 'RecBloop';
                textelement(RecordB)
                {
                    trigger OnBeforePassVariable()
                    begin
                        RecordB := RecordBTxt + CR + LF; //++CAT.002 added + LF
                    end;

                }

                trigger OnPreXmlItem() //RecordBLoop
                begin
                    RecordBLoop.SetRange(Number, 1, 1);
                end;

                trigger OnAfterGetRecord()
                begin
                    LogicalRecordCount += 1;
                    RecordBTxt := '';
                    AddToPrnString(RecordBTxt, '5', 1, 1, Justification::Left, ' ');                                                            // Record Type Code: always 5
                    AddToPrnString(RecordBTxt, '225', 2, 3, Justification::Left, ' ');                                                          // Service Class Code: always 225 - Credits only
                    AddToPrnString(RecordBTxt, CopyStr(BankAccount."CAT ACH PAD Immed. Origin Name", 1, 16), 5, 16, Justification::Left, ' ');  // Company Name
                    AddToPrnString(RecordBTxt, ' ', 21, 20, Justification::Left, ' ');                                                          // Company Discretionary Data: blanks
                    AddToPrnString(RecordBTxt, BankAccount."CAT ACH PAD Company Id.", 41, 10, Justification::Left, ' ');                        // Company Identification
                    if HasPPDTransaction then
                        AddToPrnString(RecordBTxt, 'PPD', 51, 3, Justification::Left, ' ')                                                      // Standard Entry Class Code:  PPD - entire batch must have same code
                    else
                        AddToPrnString(RecordBTxt, 'CCD', 51, 3, Justification::Left, ' ');                                                     // Standard Entry Class Code:  CCD - entire batch must have same code
                    AddToPrnString(RecordBTxt, 'CASHRECJNL', 54, 10, Justification::Left, ' ');                                                 // Company Entry Description
                    AddToPrnString(RecordBTxt, format(TransferDate, 6, '<Year><Month,2><Day,2>'), 64, 6, Justification::Left, ' ');             // Company Descriptive Date
                    AddToPrnString(RecordBTxt, format(TransferDate, 6, '<Year><Month,2><Day,2>'), 70, 6, Justification::Left, ' ');             // Effective Entry Date
                    AddToPrnString(RecordBTxt, format(JulianDate(TransferDate), 3, '<Integer>'), 76, 3, Justification::Right, '0');             // Settlement Date (Julian)
                    AddToPrnString(RecordBTxt, BankAccount."CAT ACH PAD Orig. Stat. Cd.", 79, 1, Justification::Left, ' ');                     // Originator Status Code
                    AddToPrnString(RecordBTxt, CopyStr(BankAccount."CAT ACH PAD Orig. DFI Id.", 1, 8), 80, 8, Justification::Left, ' ');        // Originating DFI Identification
                    AddToPrnString(RecordBTxt, '1', 88, 7, Justification::Right, '0');                                                          // Batch Number: default to 0000001
                end;
            }

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
                            RecordD := RecordDTxt + CR + LF; //++CAT.002 added + LF
                        end;
                    }

                    trigger OnPreXmlItem() //TempPaymentExportDataLoop
                    var
                    begin
                        ClearRecType8EntryHashSum();
                        TotalCreditEntry := 0;
                        TotalDebitEntry := 0;

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
                        ReceivingDFIId: Text[8];
                        ReceivingDFIIdCheckDigit: Text[1];
                        CCDPPDErr: Label 'value must be the same in all %1 records used in the export. Error in %1 where';
                    begin
                        if TempPaymentExportDataLoop.Number = 1 then
                            TempPaymentExportData.FindFirst()
                        else
                            TempPaymentExportData.Next();

                        CustomerBankAccount.GetBySystemId(TempPaymentExportData."CAT Cust. Bank Acc. SystemId");
                        //CustomerBankAccount.TestField("Bank Code");
                        //CustomerBankAccount.testfield("Bank Branch No.");
                        if ((CustomerBankAccount."CAT ACH PAD Account Type" = CustomerBankAccount."CAT ACH PAD Account Type"::Corporate) and HasPPDTransaction) or
                            ((CustomerBankAccount."CAT ACH PAD Account Type" = CustomerBankAccount."CAT ACH PAD Account Type"::Consumer) and HasCCDTransaction) then
                            CustomerBankAccount.FieldError(
                                "CAT ACH PAD Account Type",
                                StrSubstNo(CCDPPDErr,
                                    CustomerBankAccount.TableCaption()));

                        CustomerBankAccount.testfield("Bank Account No.");
                        GetReceivingDFIIdentificationAndCheckDigit(CustomerBankAccount, ReceivingDFIId, ReceivingDFIIdCheckDigit);
                        AddToAmountTotals(TempPaymentExportData);

                        LogicalRecordCount += 1;
                        DetailRecordCount += 1;

                        RecordDTxt := '';
                        AddToPrnString(RecordDTxt, '6', 1, 1, Justification::Left, ' ');                                                                            // Record Type Code: always 6
                        if CustomerBankAccount."CAT ACH PAD Savings Account" then
                            AddToPrnString(RecordDTxt, '37', 2, 2, Justification::Left, ' ')                                                                        // Transaction Code: 37 - Debit Savings Account
                        else
                            AddToPrnString(RecordDTxt, '27', 2, 2, Justification::Left, ' ');                                                                       // Transaction Code: 27 - Debit Checking (DDA) Account
                        AddToPrnString(RecordDTxt, copystr(DelChr(ReceivingDFIId, '<>', ' '), 1, 8), 4, 8, Justification::Left, ' ');                               // Receiving DFI Identification - first 8 digits of the routing and transit no. of the receiving bank (where the recipient account is located)
                        AddToPrnString(RecordDTxt, copystr(DelChr(ReceivingDFIIdCheckDigit, '<>', ' '), 1, 1), 12, 1, Justification::Left, ' ');                    // Check Digit - 9th digit of the routing and transit number of the receiving bank (where the recipient account is located).
                        AddToPrnString(RecordDTxt, copystr(DelChr(CustomerBankAccount."Bank Account No.", '<>', ' '), 1, 17), 13, 17, Justification::Left, ' ');    // DFI Account Number
                        AddAmtToPrnString(RecordDTxt, TempPaymentExportData.Amount, 30, 10);                                                                        // Amount
                        AddToPrnString(RecordDTxt, CustomerBankAccount."Customer No.", 40, 15, Justification::Left, ' ');                                           // Identification Number
                        AddToPrnString(RecordDTxt, CopyStr(TempPaymentExportData."Recipient Name", 1, 22), 55, 22, Justification::Left, ' ');                       // Receiving Individual/Company Name
                        AddToPrnString(RecordDTxt, ' ', 77, 2, Justification::Left, ' ');                                                                           // Discretionary Data - always blank
                        AddToPrnString(RecordDTxt, '1', 79, 1, Justification::Left, ' ');                                                                           // Addenda Record Indicator - always 1
                        AddToPrnString(RecordDTxt, '0', 80, 15, Justification::Left, '0');                                                                          // Trace Number - assigned by the ODFI in ascending sequence that uniquely identifies each entry within a batch and the file

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

            tableelement(FooterALoop; Integer)
            {
                textelement(FooterA) //Footer A record
                {
                    trigger OnBeforePassVariable()
                    begin
                        FooterA := FooterATxt + CR + LF; //++CAT.002 added + LF
                    end;
                }


                trigger OnPreXmlItem()
                begin
                    FooterALoop.SetRange(Number, 1, 1);
                end;

                trigger OnAfterGetRecord()
                begin
                    LogicalRecordCount += 1;
                    FooterATxt := '';
                    AddToPrnString(FooterATxt, '8', 1, 1, Justification::Left, ' ');                                                        // Record Type Code: always 8
                    AddToPrnString(FooterATxt, '225', 2, 3, Justification::Left, ' ');                                                      // Service Class Code: always 225
                    AddToPrnString(FooterATxt, format(DetailRecordCount, 6, '<Integer>'), 5, 6, Justification::Right, '0');                 // Entry/Addenda Count
                    AddToPrnString(FooterATxt, GetRecType8EntryHash(), 11, 10, Justification::Left, ' ');                                   // EntryHash 
                    AddAmtToPrnString(FooterATxt, TotalDebitEntry, 21, 12);                                                                 // Total Debit Entry Dollar Amount
                    AddAmtToPrnString(FooterATxt, TotalCreditEntry, 33, 12);                                                                // Total Credit Entry Dollar Amount
                    AddToPrnString(FooterATxt, BankAccount."CAT ACH PAD Company Id.", 45, 10, Justification::Left, ' ');                    // Company Identification: contains the value of the Company Identification field 5 in the Company/Batch header record
                    AddToPrnString(FooterATxt, ' ', 55, 19, Justification::Left, ' ');                                                      // Message Authentication Code: always blank
                    AddToPrnString(FooterATxt, ' ', 74, 6, Justification::Left, ' ');                                                       // Reserved: always blank
                    AddToPrnString(FooterATxt, CopyStr(BankAccount."CAT ACH PAD Orig. DFI Id.", 1, 8), 80, 8, Justification::Left, ' ');    // Originating DFI Identification: contains the value of the Originating DFI Identification field 12 of the Company/Batch Header record
                    AddToPrnString(FooterATxt, '1', 88, 7, Justification::Right, '0');                                                      // Batch Number: Contains the value of the Batch Number in field 13 of the Company/Batch Header Record.
                end;
            }

            tableelement(FooterBLoop; Integer)
            {
                textelement(FooterB) //Footer B record
                {
                    trigger OnBeforePassVariable()
                    begin
                        FooterB := FooterBTxt + CR + LF; //++CAT.002 added + LF
                    end;
                }

                trigger OnPreXmlItem()
                begin
                    FooterBLoop.SetRange(Number, 1, 1);
                end;

                trigger OnAfterGetRecord()
                begin
                    LogicalRecordCount += 1;

                    GetBlockCount(LogicalRecordCount, BlockCount, FillerCount);

                    FooterBTxt := '';
                    AddToPrnString(FooterBTxt, '9', 1, 1, Justification::Left, ' ');                                                // Record Type Code: always 9
                    AddToPrnString(FooterBTxt, '1', 2, 6, Justification::Right, '0');                                               // Batch Count: always 1
                    AddToPrnString(FooterBTxt, format(BlockCount, 0, '<Integer>'), 8, 6, Justification::Right, '0');                // Block Count
                    AddToPrnString(FooterBTxt, format(LogicalRecordCount - 4, 0, '<Integer>'), 14, 8, Justification::Right, '0');   // Entry/Addenda Count: total count - 4 headers
                    AddToPrnString(FooterBTxt, format(EntryHashTotal, 0, '<Integer>'), 22, 10, Justification::Right, '0');          // Entry Hash: The sum of the Entry Hash fields contained within the Company/Batch Control Records of the file.
                    AddAmtToPrnString(FooterBTxt, TotalDebitEntry, 32, 12);                                                         // Total Debit Entry Dollar Amount in File
                    AddAmtToPrnString(FooterBTxt, TotalCreditEntry, 44, 12);                                                        // Total Credit Entry Dollar Amount in File
                    AddToPrnString(FooterBTxt, ' ', 56, 39, Justification::Left, ' ');                                              // Reserved: always blank
                end;

            }
            tableelement(FillerLoop; Integer)
            {
                textelement(Filler) //Filler record
                {
                    trigger OnBeforePassVariable()
                    begin
                        Filler := FillerTxt + CR + LF; //++CAT.002 added + LF;
                        //use next section instead of line above if you don't want CR on last line
                        // if FillerLoop.Number = FillerCount then
                        //     Filler := FillerTxt
                        // else
                        //     Filler := FillerTxt + CR + LF;
                    end;
                }

                trigger OnPreXmlItem()
                begin
                    FillerLoop.SetRange(Number, 1, FillerCount);
                end;

                trigger OnAfterGetRecord()
                begin

                    FillerTxt := '';
                    AddToPrnString(FillerTxt, '9', 1, 94, Justification::Left, '9');    // Filler: always 9
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
        LF[1] := 10; //++CAT.002
        FileDateTime := CurrentDateTime;
        InitData();
    end;

    var
        NoDataToExportErr: Label 'There is no data to export. Make sure the %1 field is not set to %2 or %3.', Comment = '%1=Field;%2=Value;%3=Value';

    local procedure InitData()
    var
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
        DirectDebitCollection: Record "Direct Debit Collection";
        GLSetup: Record "General Ledger Setup";
        CustomerBankAccount: Record "Customer Bank Account";
        SEPADDFillExportBuffer: Codeunit "SEPA DD-Fill Export Buffer";
        TransitNo: Text;

        PaymentGroupNo: Integer;
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
        // All transactions in batch must have matching SEC code. The SEC code is determined by whether the customer bank account type is a corporate account or a consumer account. 
        // Get the first customerbankaccount and don't read every record now.
        // In later loop, will check that each customer account type matches this one.
        CustomerBankAccount.GetBySystemId(TempPaymentExportData."CAT Cust. Bank Acc. SystemId");
        if CustomerBankAccount."CAT ACH PAD Account Type" = CustomerBankAccount."CAT ACH PAD Account Type"::Corporate then
            HasCCDTransaction := true
        else
            HasPPDTransaction := true;

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

        BankAccount.TestField(BankAccount."Transit No.");
        if not GetNumericOnlyTransitNoText(BankAccount."Transit No.", TransitNo) then
            BankAccount.FieldError("Transit No.",
                StrSubstNo(Pct1MustBeNumericOnlyPct2CharsErrinPct3Err,
                    BankAccount."Transit No.",
                    '9',
                    BankAccount.TableCaption));


        BankAccount.TestField(BankAccount."CAT ACH PAD Immed. Dest. Name");
        BankAccount.TestField(BankAccount."CAT ACH PAD Immediate Dest.");
        if StrLen(delchr(BankAccount."CAT ACH PAD Immediate Dest.", '<>', ' ')) <> 9 then
            BankAccount.FieldError("CAT ACH PAD Immediate Dest.",
                StrSubstNo(Pct1MustBePct2CharsErrinPct3Err,
                    BankAccount."CAT ACH PAD Immediate Dest.",
                    '9',
                    BankAccount.TableCaption));

        BankAccount.TestField(BankAccount."CAT ACH PAD Immed. Origin Name");
        BankAccount.TestField(BankAccount."CAT ACH PAD Immediate Origin");
        if StrLen(delchr(BankAccount."CAT ACH PAD Immediate Origin", '<>', ' ')) < 9 then
            BankAccount.FieldError("CAT ACH PAD Immediate Origin",
                StrSubstNo(Pct1MustBePct2CharsErrinPct3Err,
                    BankAccount."CAT ACH PAD Immediate Origin",
                    '9 or 10',
                    BankAccount.TableCaption));

        BankAccount.TestField("CAT ACH PAD Company Name");
        BankAccount.TestField("CAT ACH PAD Company Id.");
        BankAccount.TestField("CAT ACH PAD Orig. Stat. Cd.");
        BankAccount.testfield("CAT ACH PAD Orig. DFI Id.");

        SetBankAccountFileIdModifier();

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

    local procedure SetBankAccountFileIdModifier()
    var
        OldDate: Date;
        NewDate: Date;
        OldFileIdModifier: Text[1];
        NewFileIDModifier: Text;
        FileIdModifier: Text[1];
        IncrementedStr: Text;
    begin
        OldDate := DT2Date(BankAccount."CAT Last ACH PAD File DateTime");
        NewDate := DT2Date(FileDateTime);
        OldFileIdModifier := BankAccount."CAT Last ACH PAD File ID Mod.";

        if (NewDate > OldDate) or (OldDate = 0D) or (OldFileIdModifier = '') then
            NewFileIdModifier := 'A'
        else begin //same date, need to increment the file modifier id
            IncrementedStr := IncStr(OldFileIdModifier);
            case IncrementedStr of
                '10':
                    NewFileIdModifier := 'A';
                '':
                    begin
                        FileIdModifier[1] := OldFileIdModifier[1] + 1;
                        if FileIdModifier > 'Z' then
                            FileIdModifier := '0';
                        if FileIdModifier < 'A' then
                            FileIdModifier := 'A';
                        NewFileIDModifier := FileIdModifier;
                    end;
                else
                    NewFileIdModifier := IncrementedStr;
            end;
        end;
        BankAccount."CAT Last ACH PAD File DateTime" := FileDateTime;
        BankAccount."CAT Last ACH PAD File ID Mod." := copystr(NewFileIDModifier, 1, 1);
        BankAccount.Modify();
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

    local procedure ClearRecType8EntryHashSum()
    begin
        RecType8EntryHashSum := 0;
    end;

    local procedure AddToRecType8EntryHashSum(ValidTransitNo: Text[9])
    var
        WorkInt: Integer;
        TransitNoErr: Label '%1 is not a valid Transit No. A valid Transit No. must be 9 characters and consist of digits only.';
    begin
        if Evaluate(WorkInt, ValidTransitNo) and (strlen(format(WorkInt, 0, '<Integer>')) = 9) then begin
            Evaluate(WorkInt, CopyStr(format(WorkInt, 0, '<Integer>'), 1, 8));
            RecType8EntryHashSum := RecType8EntryHashSum + WorkInt;
        end else
            Error(TransitNoErr, ValidTransitNo);
    end;

    local procedure GetRecType8EntryHash(): Text
    var
        WorkTxt: Text;
        WorkInt: Integer;
    begin
        WorkTxt := Format(RecType8EntryHashSum, 0, '<Integer>');
        if StrLen(WorkTxt) < 8 then
            WorkTxt := WorkTxt.PadLeft(8, '0');
        if strlen(WorkTxt) > 10 then //take last 10 chars
            WorkTxt := copystr(WorkTxt, strlen(WorkTxt) - 10 + 1, 10);

        evaluate(WorkInt, WorkTxt);
        EntryHashTotal += WorkInt;

        if StrLen(WorkTxt) < 10 then
            WorkTxt := WorkTxt.PadLeft(10, '0');


        exit(WorkTxt);
    end;

    local procedure GetReceivingDFIIdentificationAndCheckDigit(CustomerBankAccount: Record "Customer Bank Account"; var ReceivingDFIId: Text[8]; var ReceivingDFIIdCheckDigit: Text[1])
    var
        TransitNoTxt: Text;
    begin
        CustomerBankAccount.TestField(CustomerBankAccount."Transit No.");
        if GetNumericOnlyTransitNoText(CustomerBankAccount."Transit No.", TransitNoTxt) and (StrLen(TransitNoTxt) = 9) then begin
            AddToRecType8EntryHashSum(TransitNoTxt);
            ReceivingDFIId := CopyStr(TransitNoTxt, 1, 8);
            ReceivingDFIIdCheckDigit := CopyStr(TransitNoTxt, 9, 1);
        end else begin
            CustomerBankAccount.FieldError("Transit No.",
                StrSubstNo(Pct1MustBeNumericOnlyPct2CharsErrinPct3Err,
                    CustomerBankAccount.FieldCaption("Transit No."),
                    '9',
                    CustomerBankAccount.TableCaption));
        end;
    end;

    local procedure AddToAmountTotals(TempPaymentExportData: record "Payment Export Data" temporary);
    var
        Pct1MustBePositiveErrinPct2Err: Label '(%1) must be positive only. Error in %2 where';

    begin
        if TempPaymentExportData.Amount >= 0 then
            TotalDebitEntry += TempPaymentExportData.Amount
        else
            TotalCreditEntry += TempPaymentExportData.Amount;
        if TempPaymentExportData.Amount < 0 then
            TempPaymentExportData.FieldError("Amount",
                StrSubstNo(Pct1MustBePositiveErrinPct2Err,
                    TempPaymentExportData.FieldCaption("Transit No."),
                    TempPaymentExportData.TableCaption));
    end;

    local procedure GetNumericOnlyTransitNoText(TextIn: Text; var TextOut: Text): Boolean
    var
        WorkText: Text;
        WorkInt: Integer;
    begin
        TextOut := '';
        WorkText := DelChr(TextIn); //remove all spaces

        if StrLen(WorkText) <> 9 then
            exit(false);

        if Evaluate(WorkInt, WorkText) then begin
            TextOut := delchr(format(WorkInt, 0, '<Integer>'), '<>', ' ');
            TextOut := TextOut.PadLeft(9, '0');
            exit(true);
        end else
            exit(false);
    end;

    local procedure GetBlockCount(RecCount: Integer; var NumBlocks: Integer; var NumFillers: Integer): Integer;
    var
    begin
        if RecCount mod 10 = 0 then
            NumBlocks := (RecCount DIV 10)
        else
            NumBlocks := (RecCount DIV 10) + 1;
        Numfillers := 10 - (RecCount mod 10);
        If NumFillers = 10 then
            NumFillers := 0;
    end;

    local procedure IsNewGroup(): Boolean
    var
        DifferentTransferDateErr: label ' value of %1 does not match other transfer dates selected. All Transfer Dates must be the same. Error in %2 where';
    begin
        //test that all transfer dates are the same
        if TempPaymentExportData."Transfer Date" <> TempPaymentExportDataGroup."Transfer Date" then
            TempPaymentExportData.FieldError("Transfer Date", StrSubstNo(DifferentTransferDateErr, TempPaymentExportData."Transfer Date", TempPaymentExportData.FieldCaption("Transfer Date")));

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
        TransferDate := TempPaymentExportDataGroup."Transfer Date";
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
        RecordBTxt: Text;
        RecordDTxt: Text;
        FooterATxt: Text;
        FooterBTxt: Text;
        FillerTxt: Text;
        CR: Text[1];
        LF: Text[1]; //++CAT.002
        DCount: Integer;
        DControlTotal: Decimal;
        CCount: Integer;
        CControlTotal: Decimal;
        LogicalRecordCount: Integer;
        FileDateTime: DateTime;
        FileCreationNoTxt: Text;
        DestinationDataCenterTxt: Text[5];
        CurrCodeTxt: Text[3];
        TransferDate: Date;
        RecType8EntryHashSum: Integer;
        TotalDebitEntry: Decimal;
        TotalCreditEntry: Decimal;
        FillerCount: Integer;
        BlockCount: Integer;
        EntryHashTotal: Integer;
        HasCCDTransaction: Boolean;
        HasPPDTransaction: Boolean;

        Pct1MustBePct2CharsErrinPct3Err: Label '(%1) must be %2 characters long. Error in %3 where';
        Pct1MustBeNumericOnlyPct2CharsErrinPct3Err: Label '(%1) must be numeric only and must be %2 characters long. Error in %3 where';

}