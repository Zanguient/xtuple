CREATE OR REPLACE FUNCTION invReceipt(INTEGER, NUMERIC, TEXT, TEXT, TEXT) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN invReceipt($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, NULL);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION invReceipt(INTEGER, NUMERIC, TEXT, TEXT, TEXT, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN invReceipt($1, $2, $3, $4, $5, $6, NULL);
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS invReceipt(INTEGER, NUMERIC, TEXT, TEXT, TEXT, TIMESTAMP WITH TIME ZONE, NUMERIC);

CREATE OR REPLACE FUNCTION invReceipt(pItemsiteId INTEGER, 
                                      pQty NUMERIC, 
                                      pOrderNumber TEXT, 
                                      pDocumentNumber TEXT, 
                                      pComments TEXT, 
                                      pGlDistTS TIMESTAMP WITH TIME ZONE, 
                                      pCostValue NUMERIC,
                                      pItemlocSeries INTEGER DEFAULT NULL) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _invhistId      INTEGER;
  _itemlocSeries  INTEGER;

BEGIN
--  Make sure the passed itemsite points to a real item
  IF ( ( SELECT (item_type IN ('R', 'F') OR itemsite_costmethod = 'J')
         FROM itemsite, item
         WHERE ( (itemsite_item_id=item_id)
          AND (itemsite_id=pItemsiteId) ) ) ) THEN
    RETURN 0;
  END IF;

  -- pItemlocSeries is passed from materialReceiptTrans.cpp post #22868. 
  -- pItemlocSeries prevents postInvTrans (pPreDistributed) from creating itemlocdist records again.
  _itemlocSeries := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));
  SELECT postInvTrans(itemsite_id, 'RX', pQty,
                       'I/M', 'RX', pDocumentNumber, '',
                       ('Miscellaneous Receipt for item ' || item_number || E'\n' ||  pComments),
                       costcat_asset_accnt_id, costcat_adjustment_accnt_id,
                       _itemlocSeries, pGlDistTS, pCostValue, NULL, NULL, COALESCE(pItemlocSeries, 0) != 0) INTO _invhistId
  FROM itemsite, item, costcat
  WHERE ( (itemsite_item_id=item_id)
   AND (itemsite_costcat_id=costcat_id)
   AND (itemsite_id=pItemsiteId) );

  RETURN _itemlocSeries;

END;
$$ LANGUAGE plpgsql;
