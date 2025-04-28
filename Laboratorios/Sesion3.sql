DECLARE
	v_cantidad NUMBER := 900;
BEGIN
	IF v_cantidad > 1000 THEN
		DBMS_OUTPUT.PUT_LINE('Es grande: ' || v_cantidad);
	ELSE IF v_cantidad > 500 THEN
		DBMS_OUTPUT.PUT_LINE('Es mediano' || v_cantidad);
	ELSE
		DBMS_OUTPUT.PUT_LINE('Es bajo' || v_cantidad);
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUTLINE('No se encontraron los datos necesarios' || v_cantidad);

END;