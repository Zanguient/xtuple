CREATE OR REPLACE FUNCTION formatWeight(NUMERIC) RETURNS TEXT IMMUTABLE AS $$
-- Copyright (c) 1999-2019 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
SELECT formatNumeric($1, 'weight') AS result
$$ LANGUAGE 'sql';
