CREATE OR REPLACE FUNCTION reverseCashReceiptDisc(INTEGER, INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2016 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pCashrcptItemId ALIAS FOR $1;
  pJournalNumber ALIAS FOR $2;
  _r RECORD;
  _t RECORD;
  _v RECORD;
  _ardiscountid INTEGER;
  _arMemoNumber TEXT;
  _arAccntid INTEGER;
  _discountAccntid INTEGER;
  _comment      TEXT;
  _discprcnt NUMERIC;
  _check INTEGER;
  _taxheadid INTEGER;
  _taxlineid INTEGER;

BEGIN

    -- Fetch base records for processing
    SELECT aropen_id, aropen_doctype, aropen_amount,
           cashrcptitem_discount,
           cashrcptitem_cust_id, cashrcpt_distdate, cashrcpt_applydate,
           cashrcpt_curr_id, cashrcpt_fundstype, cashrcpt_docnumber,
           round(currToCurr(cashrcpt_curr_id, aropen_curr_id, cashrcptitem_discount, cashrcpt_distdate),2) AS aropen_discount
      INTO _r
    FROM cashrcptitem 
      JOIN cashrcpt ON (cashrcptitem_cashrcpt_id=cashrcpt_id)
      JOIN aropen ON ( (aropen_id=cashrcptitem_aropen_id) AND (aropen_doctype IN ('I', 'D')) )
    WHERE (cashrcptitem_id=pCashrcptItemId);

    -- Get discount account
    _discountAccntid := findardiscountaccount(_r.cashrcptitem_cust_id);
  
    IF (_r.cashrcptitem_discount > 0) THEN
      --  Determine discount percentage
      _discprcnt := _r.aropen_discount / _r.aropen_amount;

      SELECT fetchArMemoNumber() INTO _arMemoNumber;
      _comment := 'Discount Credit Reversal from ' || _r.cashrcpt_fundstype || '-' || _r.cashrcpt_docnumber;

      -- Create misc debit memo record
      _ardiscountid := nextval('aropen_aropen_id_seq');
      INSERT INTO aropen (
        aropen_id, aropen_docdate, aropen_duedate, aropen_doctype, 
        aropen_docnumber, aropen_curr_id, aropen_posted, aropen_amount ) 
      VALUES ( 
        _ardiscountid, _r.cashrcpt_distdate, _r.cashrcpt_distdate, 'D', 
        _arMemoNumber, _r.cashrcpt_curr_id, false,_r.cashrcptitem_discount);
        
      IF (fetchMetricBool('CreditTaxDiscount')) THEN
        --  proportional tax credits calculated and implemented for the debit memo generated by the discount
        IF (_r.aropen_doctype  = 'I') THEN
          -- Tax for invoices
          INSERT INTO taxhead (taxhead_status, taxhead_doc_type, taxhead_doc_id, taxhead_cust_id,
                               taxhead_date, taxhead_curr_id,
                               taxhead_curr_rate, taxhead_taxzone_id)
          SELECT 'P', 'AR', _ardiscountid, _r.cashrcptitem_cust_id,
                 _r.cashrcpt_distdate, _r.cashrcpt_curr_id,
                 currRate(_r.cashrcpt_curr_id, _r.cashrcpt_distdate), taxhead_taxzone_id
            FROM taxhead
           WHERE taxhead_doc_type = 'INV'
             AND taxhead_doc_id = _t.invcheadid
          RETURNING taxhead_id INTO _taxheadid;

          INSERT INTO taxline (taxline_taxhead_id, taxline_line_type, taxline_line_id, taxline_qty,
                               taxline_amount, taxline_extended)
          SELECT _taxheadid, 'L', _ardiscountid, 1.0,
                 _r.cashrcptitem_discount, _r.cashrcptitem_discount
          RETURNING taxline_id INTO _taxlineid;

          INSERT INTO taxdetail (taxdetail_taxline_id, taxdetail_taxable, taxdetail_tax_id,
                                 taxdetail_taxclass_id, taxdetail_sequence, taxdetail_basis_tax_id,
                                 taxdetail_amount, taxdetail_percent, taxdetail_tax)
          SELECT _taxlineid, taxdetail_taxable * _discprcnt, taxdetail_tax_id,
                 taxdetail_taxclass_id, taxdetail_sequence, taxdetail_basis_tax_id,
                 taxdetail_amount, taxdetail_percent, taxdetail_tax * _discprcnt
            FROM taxhead
            JOIN taxline ON taxhead_id = taxline_taxhead_id
            JOIN taxdetail ON taxline_id = taxdetail_taxline_id
           WHERE taxhead_doc_type = 'INV'
             AND taxhead_doc_id = _t.invcheadid;
        ELSIF (_r.aropen_doctype  = 'D') THEN
          -- Tax for debit memos
          INSERT INTO taxhead (taxhead_doc_type, taxhead_doc_id, taxhead_cust_id, taxhead_date,
                               taxhead_curr_id, taxhead_curr_rate,
                               taxhead_taxzone_id)
          SELECT 'AR', _ardiscountid, _r.cashrcptitem_cust_id, _r.cashrcpt_distdate,
                 _r.cashrcpt_curr_id, currRate(_r.cashrcpt_curr_id, _r.cashrcpt_distdate),
                 taxhead_taxzone_id
            FROM taxhead
           WHERE taxhead_doc_type = 'AR'
             AND taxhead_doc_id = _r.aropen_id
          RETURNING taxhead_id INTO _taxheadid;

          INSERT INTO taxline (taxline_taxhead_id, taxline_line_type, taxline_line_id, taxline_qty,
                               taxline_amount, taxline_extended)
          SELECT _taxheadid, 'L', _ardiscountid, 1.0,
                 _r.cashrcptitem_discount, _r.cashrcptitem_discount
          RETURNING taxline_id INTO _taxlineid;

          INSERT INTO taxdetail (taxdetail_taxline_id, taxdetail_taxable, taxdetail_tax_id,
                                 taxdetail_taxclass_id, taxdetail_sequence, taxdetail_basis_tax_id,
                                 taxdetail_amount, taxdetail_percent, taxdetail_tax)
          SELECT _taxlineid, taxdetail_taxable * _discprcnt, taxdetail_tax_id,
                 taxdetail_taxclass_id, taxdetail_sequence, taxdetail_basis_tax_id,
                 taxdetail_amount, taxdetail_percent, taxdetail_tax * _discprcnt
            FROM taxhead
            JOIN taxline ON taxhead_id = taxline_taxhead_id
            JOIN taxdetail ON taxline_id = taxdetail_taxline_id
           WHERE taxhead_doc_type = 'AR'
             AND taxhead_doc_id = _r.aropen_id;
        END IF;
      END IF; -- End taxes

      -- Create negative credit memo for discount
      SELECT createARCreditMemo(_ardiscountid, _r.cashrcptitem_cust_id, _arMemoNumber, '',
                                _r.cashrcpt_distdate, (_r.cashrcptitem_discount * -1.0),
                                _comment, -1, -1, _discountAccntid, _r.cashrcpt_distdate,
                                -1, NULL, 0,
                                pJournalNumber, _r.cashrcpt_curr_id) INTO _ardiscountid;

      -- Apply discount negative credit memo
      INSERT INTO arcreditapply ( 
        arcreditapply_source_aropen_id, arcreditapply_target_aropen_id,
        arcreditapply_amount, arcreditapply_curr_id )
      VALUES ( 
        _ardiscountid, _r.aropen_id, (_r.cashrcptitem_discount * -1.0), _r.cashrcpt_curr_id );
 
      SELECT postARCreditMemoApplication(_ardiscountid, _r.cashrcpt_applydate) INTO _check;
      IF (_check < 0) THEN
        RAISE EXCEPTION 'Error posting discount credit memo application. Code %', _check;
      END IF;

    END IF; -- End handle Discount

    RETURN 1;

END;
$$ LANGUAGE 'plpgsql';
