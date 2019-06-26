CREATE OR REPLACE PROCEDURE PROC_SEND_EMAIL(P_TXT      VARCHAR2,
                                            P_SUB      VARCHAR2,
                                            P_SENDOR   VARCHAR2,
                                            P_RECEIVER VARCHAR2,
                                            P_SERVER   VARCHAR2,
                                            P_PORT     NUMBER DEFAULT 25,
                                            --  P_NEED_SMTP INT DEFAULT 0,
                                            --  P_USER      VARCHAR2 DEFAULT NULL,
                                            P_PASS VARCHAR2 DEFAULT NULL,
                                            P_Dir  varchar2 DEFAULT 'MAIL_DIR',
                                            -- P_FILENAME  VARCHAR2 DEFAULT NULL,
                                            P_QUERY  IN VARCHAR2,
                                            P_ENCODE VARCHAR2 DEFAULT 'bit 7')
  AUTHID CURRENT_USER IS

  L_CRLF          VARCHAR2(2) := UTL_TCP.CRLF;
  L_SENDORADDRESS VARCHAR2(4000);
  L_SPLITE        VARCHAR2(10) := '++';
  BOUNDARY            CONSTANT VARCHAR2(256) := '-----BYSUK';
  FIRST_BOUNDARY      CONSTANT VARCHAR2(256) := '--' || BOUNDARY || L_CRLF;
  LAST_BOUNDARY       CONSTANT VARCHAR2(256) := '--' || BOUNDARY || '--' ||
                                                L_CRLF;
  MULTIPART_MIME_TYPE CONSTANT VARCHAR2(256) := 'multipart/mixed; boundary="' ||
                                                BOUNDARY || '"';
  P_FILENAME VARCHAR2(100);

  L_FIL                 BFILE;
  L_FILE_LEN            NUMBER;
  L_MODULO              NUMBER;
  L_PIECES              NUMBER;
  L_FILE_HANDLE         UTL_FILE.FILE_TYPE;
  L_AMT                 BINARY_INTEGER := 672 * 3; /* ensures proper format;  2016 */
  L_FILEPOS             PLS_INTEGER := 1; /* pointer for the file */
  L_CHUNKS              NUMBER;
  L_BUF                 RAW(2100);
  L_DATA                RAW(2100);
  L_MAX_LINE_WIDTH      NUMBER := 54;
  L_DIRECTORY_BASE_NAME VARCHAR2(100) := 'DIR_FOR_SEND_MAIL';
  L_LINE                VARCHAR2(1000);
  L_MESG                VARCHAR2(32767);

  TYPE ADDRESS_LIST IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  MY_ADDRESS_LIST ADDRESS_LIST;
  TYPE ACCT_LIST IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  MY_ACCT_LIST ACCT_LIST;
  -------------------------------------return file directory or file name--------------------------------------
  FUNCTION GET_FILE(P_FILE VARCHAR2, P_GET INT) RETURN VARCHAR2 IS
    --p_get=1 return file directory
    --p_get=2 return file name
    L_FILE VARCHAR2(1000);
  BEGIN
    IF INSTR(P_FILE, '\') > 0 THEN
      --windows
      IF P_GET = 1 THEN
        L_FILE := SUBSTR(P_FILE, 1, INSTR(P_FILE, '\', -1) - 1);
      ELSIF P_GET = 2 THEN
        L_FILE := SUBSTR(P_FILE, - (LENGTH(P_FILE) - INSTR(P_FILE, '\', -1)));
      END IF;
    ELSIF INSTR(P_FILE, '/') > 0 THEN
      --linux/unix
      IF P_GET = 1 THEN
        L_FILE := SUBSTR(P_FILE, 1, INSTR(P_FILE, '/', -1) - 1);
      ELSIF P_GET = 2 THEN
        L_FILE := SUBSTR(P_FILE, - (LENGTH(P_FILE) - INSTR(P_FILE, '/', -1)));
      END IF;
    END IF;
    RETURN L_FILE;
  END;
  ---------------------------------------------delete directory------------------------------------
  PROCEDURE DROP_DIRECTORY(P_DIRECTORY_NAME VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'drop directory ' || P_DIRECTORY_NAME;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  --------------------------------------------------create directory-----------------------------------------
  PROCEDURE CREATE_DIRECTORY(P_DIRECTORY_NAME VARCHAR2, P_DIR VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'create directory ' || P_DIRECTORY_NAME || ' as ''' ||P_DIR || '''';
    EXECUTE IMMEDIATE 'grant read,write on directory ' || P_DIRECTORY_NAME ||' to public';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
  -------------------------------------------select data export csv file-------------------------------------------
  PROCEDURE SQL_TO_CSV(P_QUERY    IN VARCHAR2, -- PLSQL
                       P_DIR      IN VARCHAR2, -- Export file placement address
                       P_FILENAME IN VARCHAR2 -- CSV file name
                       ) IS
    L_OUTPUT       UTL_FILE.FILE_TYPE;
    L_THECURSOR    INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
    L_COLUMNVALUE  VARCHAR2(4000);
    L_STATUS       INTEGER;
    L_COLCNT       NUMBER := 0;
    L_SEPARATOR    VARCHAR2(1);
    L_DESCTBL      DBMS_SQL.DESC_TAB;
    P_MAX_LINESIZE NUMBER := 32000;
  BEGIN
    --OPEN FILE
    L_OUTPUT := UTL_FILE.FOPEN(P_DIR, P_FILENAME, 'W', P_MAX_LINESIZE);
    --DEFINE DATE FORMAT
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYY-MM-DD HH24:MI:SS''';
    --OPEN CURSOR
    -- DBMS_SQL.close_cursor(L_THECURSOR);
    DBMS_SQL.PARSE(L_THECURSOR, P_QUERY, DBMS_SQL.NATIVE);
    DBMS_SQL.DESCRIBE_COLUMNS(L_THECURSOR, L_COLCNT, L_DESCTBL);
    --DUMP TABLE COLUMN NAME
    FOR I IN 1 .. L_COLCNT LOOP
      UTL_FILE.PUT(L_OUTPUT, L_SEPARATOR || '"' || L_DESCTBL(I).COL_NAME || '"');
      DBMS_SQL.DEFINE_COLUMN(L_THECURSOR, I, L_COLUMNVALUE, 4000);
      L_SEPARATOR := ',';
    END LOOP;
    UTL_FILE.NEW_LINE(L_OUTPUT);
    --EXECUTE THE QUERY STATEMENT
    L_STATUS := DBMS_SQL.EXECUTE(L_THECURSOR);
  
    --DUMP TABLE COLUMN VALUE
    WHILE (DBMS_SQL.FETCH_ROWS(L_THECURSOR) > 0) LOOP
      L_SEPARATOR := '';
      FOR I IN 1 .. L_COLCNT LOOP
        DBMS_SQL.COLUMN_VALUE(L_THECURSOR, I, L_COLUMNVALUE);
        UTL_FILE.PUT(L_OUTPUT,L_SEPARATOR || '"' || TRIM(BOTH ' ' FROM REPLACE(L_COLUMNVALUE, '"', '""')) || '"');
        L_SEPARATOR := ',';
      END LOOP;
      UTL_FILE.NEW_LINE(L_OUTPUT);
    END LOOP;
    --CLOSE CURSOR
    DBMS_SQL.CLOSE_CURSOR(L_THECURSOR);
    --CLOSE FILE
    UTL_FILE.FCLOSE(L_OUTPUT);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  --------------------------------------------address and ATTACHMENT file address-----------------------------------
  PROCEDURE P_SPLITE_STR(P_STR VARCHAR2, P_SPLITE_FLAG INT DEFAULT 1) IS
    L_ADDR VARCHAR2(254) := '';
    L_LEN  INT;
    L_STR  VARCHAR2(4000);
    J      INT := 0;
  BEGIN
  
    L_STR := TRIM(RTRIM(REPLACE(REPLACE(P_STR, ';', ','), ' ', ''), ','));
    L_LEN := LENGTH(L_STR);
    FOR I IN 1 .. L_LEN LOOP
      IF SUBSTR(L_STR, I, 1) <> ',' THEN
        L_ADDR := L_ADDR || SUBSTR(L_STR, I, 1);
      ELSE
        J := J + 1;
        IF P_SPLITE_FLAG = 1 THEN
          L_ADDR := '<' || L_ADDR || '>';
          MY_ADDRESS_LIST(J) := L_ADDR;
        ELSIF P_SPLITE_FLAG = 2 THEN
          MY_ACCT_LIST(J) := L_ADDR;
        END IF;
        L_ADDR := '';
      END IF;
      IF I = L_LEN THEN
        J := J + 1;
        IF P_SPLITE_FLAG = 1 THEN
          L_ADDR := '<' || L_ADDR || '>';
          MY_ADDRESS_LIST(J) := L_ADDR;
        ELSIF P_SPLITE_FLAG = 2 THEN
          MY_ACCT_LIST(J) := L_ADDR;
        END IF;
      END IF;
    END LOOP;
  END;
  ------------------------------------------------write emailheader and email body------------------------------------------
  PROCEDURE WRITE_DATA(P_CONN   IN OUT NOCOPY UTL_SMTP.CONNECTION,
                       P_NAME   IN VARCHAR2,
                       P_VALUE  IN VARCHAR2,
                       P_SPLITE VARCHAR2 DEFAULT ':',
                       P_CRLF   VARCHAR2 DEFAULT L_CRLF) IS
  BEGIN
    /* utl_raw.cast_to_raw */
    UTL_SMTP.WRITE_RAW_DATA(P_CONN, UTL_RAW.CAST_TO_RAW(CONVERT(P_NAME || P_SPLITE ||P_VALUE || P_CRLF,'AL32UTF8')));
  END;
  ----------------------------------------write email last-----------------------------------------------------

  PROCEDURE END_BOUNDARY(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION,LAST IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
    IF (LAST) THEN
      UTL_SMTP.WRITE_DATA(CONN, LAST_BOUNDARY);
    END IF;
  END;

  ----------------------------------------------send ATTACHMENT----------------------------------------------------

  PROCEDURE ATTACHMENT(CONN         IN OUT NOCOPY UTL_SMTP.CONNECTION,
                       MIME_TYPE    IN VARCHAR2 DEFAULT 'txt/csv',
                       INLINE       IN BOOLEAN DEFAULT TRUE,
                       FILENAME     IN VARCHAR2 DEFAULT 't.csv',
                       TRANSFER_ENC IN VARCHAR2 DEFAULT '7 bit',
                       DT_NAME      IN VARCHAR2 DEFAULT '0') IS
  
    L_FILENAME VARCHAR2(1000);
    H_FILENAME VARCHAR2(1000);
  BEGIN
    UTL_SMTP.WRITE_DATA(CONN, FIRST_BOUNDARY);
    WRITE_DATA(CONN, 'Content-Type', MIME_TYPE);
    H_FILENAME := GET_FILE(FILENAME, 1);
  
    L_FILENAME := P_FILENAME;
  
    IF (INLINE) THEN
      WRITE_DATA(CONN, 'Content-Disposition','inline; filename="' || L_FILENAME || '"');
    ELSE
      WRITE_DATA(CONN,'Content-Disposition','attachment; filename="' || L_FILENAME || '"');
    END IF;
  
    IF (TRANSFER_ENC IS NOT NULL) THEN
      WRITE_DATA(CONN, 'Content-Transfer-Encoding', TRANSFER_ENC);
    END IF;
  
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
  
    IF TRANSFER_ENC = 'bit 7' THEN
    
      BEGIN
        L_FILE_HANDLE := UTL_FILE.FOPEN(DT_NAME, L_FILENAME, 'r');
      
        LOOP
          UTL_FILE.GET_LINE(L_FILE_HANDLE, L_LINE);
          L_MESG := L_LINE || L_CRLF;
          WRITE_DATA(CONN, '', L_MESG, '', '');
        END LOOP;
        UTL_FILE.FCLOSE(L_FILE_HANDLE);
        END_BOUNDARY(CONN);
      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.FCLOSE(L_FILE_HANDLE);
          END_BOUNDARY(CONN);
          NULL;
      END;
    
    ELSIF TRANSFER_ENC = 'base64' THEN
    
      BEGIN
      
        L_FILEPOS  := 1;
        L_FIL      := BFILENAME(DT_NAME, L_FILENAME);
        L_FILE_LEN := DBMS_LOB.GETLENGTH(L_FIL);
        L_MODULO   := MOD(L_FILE_LEN, L_AMT);
        L_PIECES   := TRUNC(L_FILE_LEN / L_AMT);
        IF (L_MODULO <> 0) THEN
          L_PIECES := L_PIECES + 1;
        END IF;
        DBMS_LOB.FILEOPEN(L_FIL, DBMS_LOB.FILE_READONLY);
        DBMS_LOB.READ(L_FIL, L_AMT, L_FILEPOS, L_BUF);
        L_DATA := NULL;
        FOR I IN 1 .. L_PIECES LOOP
          L_FILEPOS  := I * L_AMT + 1;
          L_FILE_LEN := L_FILE_LEN - L_AMT;
          L_DATA     := UTL_RAW.CONCAT(L_DATA, L_BUF);
          L_CHUNKS   := TRUNC(UTL_RAW.LENGTH(L_DATA) / L_MAX_LINE_WIDTH);
          IF (I <> L_PIECES) THEN
            L_CHUNKS := L_CHUNKS - 1;
          END IF;
          UTL_SMTP.WRITE_RAW_DATA(CONN, UTL_ENCODE.BASE64_ENCODE(L_DATA));
          L_DATA := NULL;
          IF (L_FILE_LEN < L_AMT AND L_FILE_LEN > 0) THEN
            L_AMT := L_FILE_LEN;
          END IF;
          DBMS_LOB.READ(L_FIL, L_AMT, L_FILEPOS, L_BUF);
        END LOOP;
        DBMS_LOB.FILECLOSE(L_FIL);
        END_BOUNDARY(CONN);
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_LOB.FILECLOSE(L_FIL);
          END_BOUNDARY(CONN);
          RAISE;
      END;
    
    END IF;
  
  END;

  ---------------------------------------------true send email--------------------------------------------
  PROCEDURE P_EMAIL(P_SENDORADDRESS2   VARCHAR2, --send email 
                    P_RECEIVERADDRESS2 VARCHAR2) --receiver email
   IS
    L_CONN          UTL_SMTP.CONNECTION; --connection
    l_http_request  UTL_HTTP.req;
    l_http_response UTL_HTTP.resp;
    l_text          VARCHAR2(32767);
  BEGIN
  
    L_CONN := UTL_SMTP.OPEN_CONNECTION(P_SERVER,
                                       P_PORT,
                                       wallet_path                   => 'file:/opt/oracle/wlt',
                                       wallet_password               => P_PASS,
                                       secure_connection_before_smtp => false);
  
    UTL_SMTP.EHLO(L_CONN, P_SERVER);
  
    UTL_SMTP.MAIL(L_CONN, P_SENDORADDRESS2);
    UTL_SMTP.RCPT(L_CONN, P_RECEIVERADDRESS2);
  
    UTL_SMTP.OPEN_DATA(L_CONN);
  
    WRITE_DATA(L_CONN, 'Date', TO_CHAR(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
  
    WRITE_DATA(L_CONN, 'From', P_SENDOR);
  
    WRITE_DATA(L_CONN, 'To', P_RECEIVER);
  
    WRITE_DATA(L_CONN, 'Subject', P_SUB);
  
    WRITE_DATA(L_CONN, 'Content-Type', MULTIPART_MIME_TYPE);
    UTL_SMTP.WRITE_DATA(L_CONN, UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(L_CONN, FIRST_BOUNDARY);
    WRITE_DATA(L_CONN, 'Content-Type', 'text/plain;charset=UTF-8');
  
    UTL_SMTP.WRITE_DATA(L_CONN, UTL_TCP.CRLF);
  
    WRITE_DATA(L_CONN,'', REPLACE(REPLACE(REPLACE(P_TXT,'{0}',to_char(sysdate,'dd-MM-yyyy')), L_SPLITE, CHR(10)), CHR(10), L_CRLF), '','');
    END_BOUNDARY(L_CONN);
  
    IF (P_FILENAME IS NOT NULL) THEN
    
      P_SPLITE_STR(P_FILENAME, 2);
    
      FOR K IN 1 .. MY_ACCT_LIST.COUNT LOOP
      
        ATTACHMENT(CONN         => L_CONN,
                   FILENAME     => MY_ACCT_LIST(K),
                   TRANSFER_ENC => P_ENCODE,
                   DT_NAME      => P_Dir); --L_DIRECTORY_BASE_NAME || TO_CHAR(K)
      END LOOP;
    END IF;
    UTL_SMTP.CLOSE_DATA(L_CONN);
    UTL_SMTP.QUIT(L_CONN);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
      RAISE;
    
  END;

  ---------------------------------------------------main procdure-----------------------------------------------------

BEGIN
  L_SENDORADDRESS := '<' || P_SENDOR || '>';
  P_FILENAME      := 'CTQ_' || to_char(sysdate, 'dd-MM-yyyy') || '.csv';
  P_SPLITE_STR(P_RECEIVER);
 
  SQL_TO_CSV(P_QUERY, P_Dir, P_FILENAME);
  FOR K IN 1 .. MY_ADDRESS_LIST.COUNT LOOP
    P_EMAIL(L_SENDORADDRESS, MY_ADDRESS_LIST(K));
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END PROC_SEND_EMAIL;
