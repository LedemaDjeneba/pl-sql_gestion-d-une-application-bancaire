--========================================
--////// LOT 1 \\\\\\
--========================================


DROP TABLE BANQUE CASCADE CONSTRAINT;
DROP TABLE OPERATION CASCADE CONSTRAINT;
DROP TABLE COMPTE CASCADE CONSTRAINT;
DROP TABLE TYPECOMPTE CASCADE CONSTRAINT;
DROP TABLE AUDITDECOUVERT CASCADE CONSTRAINT;

--*Création table BANQUE*
CREATE TABLE BANQUE
(
    IdBanque INTEGER,
    LibelleBanque VARCHAR(50) NOT NULL,
    CPBanque CHAR(5) NOT NULL,
    AdresseBanque VARCHAR(50) NOT NULL,
    VilleBanque VARCHAR(30) NOT NULL
);

DROP SEQUENCE SeqIdBanque;
CREATE SEQUENCE SeqIdBanque START WITH 10000 INCREMENT BY 10;
ALTER TABLE BANQUE ADD CONSTRAINT PK_IdBanque PRIMARY KEY(IdBanque);
ALTER TABLE BANQUE ADD CONSTRAINT U_LibelleBanque UNIQUE(LibelleBanque);

--*Création table AUDITDECOUVERT*
CREATE TABLE AUDITDECOUVERT
(
    IdAudit INTEGER,
    IdCompte INTEGER NOT NULL,
    LibelleCompte VARCHAR(30) NOT NULL,
    SoldeCompte NUMBER(10,2) NOT NULL,
    DecouvertAutorise NUMBER(10,2) NOT NULL,
    Depassement NUMBER(10,2) NOT NULL,
    IdDerniereOperation INTEGER NOT NULL
);

DROP SEQUENCE SeqIdAudit;
CREATE SEQUENCE SeqIdAudit;

--*Création table TYPECOMPTE*
CREATE TABLE TYPECOMPTE
(
    IdTypeCompte INTEGER,
    LibelleTypeCompte VARCHAR(30) NOT NULL
);

DROP SEQUENCE SeqIdTypeCompte;
CREATE SEQUENCE SeqIdTypeCompte;
ALTER TABLE TYPECOMPTE ADD CONSTRAINT PK_IdTypeCompte PRIMARY KEY(IdTypeCompte);

--*Création table OPERATION*
CREATE TABLE OPERATION
(
    IdOperation INTEGER,
    DateOperation DATE NOT NULL,
    MontantOperation NUMBER(10,2) NOT NULL
);

DROP SEQUENCE SeqIdOperation;
CREATE SEQUENCE SeqIdOperation;
ALTER TABLE OPERATION ADD CONSTRAINT PK_IdOperation PRIMARY KEY(IdOperation);

--*Création table COMPTE*
CREATE TABLE COMPTE
(
    IdCompte INTEGER,
    LibelleCompte VARCHAR(30) NOT NULL,
    SoldeCompte NUMBER(10,2) NOT NULL,
    DecouvertAutorise NUMBER(10,2) NOT NULL,
    DateOuvertureCompte DATE NOT NULL
);

DROP SEQUENCE SeqIdCompte;
CREATE SEQUENCE SeqIdCompte;
ALTER TABLE COMPTE ADD CONSTRAINT PK_IdCompte PRIMARY KEY(IdCompte);
ALTER TABLE COMPTE ADD CONSTRAINT U_LibelleCompte UNIQUE(LibelleCompte);

--*Ajout de clés étrangère dans COMPTE et OPERATION*
ALTER TABLE COMPTE ADD (IdBanque INTEGER);
ALTER TABLE COMPTE MODIFY (IdBanque INTEGER CONSTRAINT FK_IdBanque REFERENCES BANQUE(IdBanque));
ALTER TABLE COMPTE MODIFY (IdBanque NOT NULL);
ALTER TABLE COMPTE ADD (IdTypeCompte INTEGER);
ALTER TABLE COMPTE MODIFY (IdTypeCompte INTEGER CONSTRAINT FK_IdTypeCompte REFERENCES TYPECOMPTE(IdTypeCompte));
ALTER TABLE COMPTE MODIFY (IdTypeCompte NOT NULL);
ALTER TABLE OPERATION ADD (IdCompte INTEGER);
ALTER TABLE OPERATION MODIFY (IdCompte INTEGER CONSTRAINT FK_IdCompte REFERENCES COMPTE(IdCompte));
ALTER TABLE OPERATION MODIFY (IdCompte NOT NULL);

--*insertion de données table type compte*
insert into TYPECOMPTE (IdTypeCompte,LibelleTypeCompte) values(SeqIdTypeCompte.NEXTVAL, 'LIVRET
A');
insert into TYPECOMPTE (IdTypeCompte,LibelleTypeCompte) values(SeqIdTypeCompte.NEXTVAL,'Compte Courant');
insert into TYPECOMPTE (IdTypeCompte,LibelleTypeCompte) values(SeqIdTypeCompte.NEXTVAL,'Livret Développement Durable');
insert into TYPECOMPTE (IdTypeCompte,LibelleTypeCompte) values(SeqIdTypeCompte.NEXTVAL,'PEL');
insert into TYPECOMPTE (IdTypeCompte,LibelleTypeCompte) values(SeqIdTypeCompte.NEXTVAL,'CEL');

--*insertion de données table banque*
insert into BANQUE (IdBanque,LibelleBanque,CPBanque,VilleBanque,AdresseBanque) values(SeqIdBanque.NEXTVAL, 'LBP','93000','BOBIGNY','Rue du chemin vert');
insert into BANQUE (IdBanque,LibelleBanque,CPBanque,VilleBanque,AdresseBanque) values(SeqIdBanque.NEXTVAL, 'SG','77580','CRECY LA CHAPELLE','Rue du general Leclerc');

--*insertion de données table compte*
insert into COMPTE (IdCompte,LibelleCompte,SoldeCompte,DecouvertAutorise,DateOuvertureCompte,IdBanque,IdTypeCompte) 
values(SeqIdCompte.NEXTVAL, 'TOURE',10000,30000,SYSDATE,10010,2);
insert into COMPTE (IdCompte,LibelleCompte,SoldeCompte,DecouvertAutorise,DateOuvertureCompte,IdBanque,IdTypeCompte) 
values(SeqIdCompte.NEXTVAL, 'KABIR',100000,100000,TO_DATE('20150401','YYYYMMDD'),10000,2);

--*question1--
CREATE OR REPLACE PROCEDURE ajoutnoucvoperation(idcompte INTEGER, value NUMBER)
IS
BEGIN
	INSERT INTO operation(IdOperation,DateOperation,MontantOperation,IdCompte)
	values(SeqIdOperation.NEXTVAL,SYSDATE,value,idcompte);
END ajoutnoucvoperation;

--*test question1--
EXECUTE ajoutnoucvoperation (1,1000);

--*question2--
CREATE OR REPLACE PROCEDURE annuleroperation(idopt INTEGER)
IS
mtoperation NUMBER(10,2);
idcpte INTEGER;
BEGIN
	SELECT montantoperation,IdCompte INTO mtoperation,idcpte from operation  
	WHERE IdOperation = idopt;
	INSERT INTO operation(IdOperation,DateOperation,MontantOperation,IdCompte)
	values(SeqIdOperation.NEXTVAL,SYSDATE,(mtoperation*-1),idcpte);
END annuleroperation;

--test question 2-
EXECUTE annuleroperation(1);
SELECT * FROM OPERATION;

	
--*question3--	
CREATE OR REPLACE PROCEDURE majdecouvertautorise (idcpte INTEGER, value NUMBER)
IS
BEGIN
	UPDATE COMPTE
	SET DecouvertAutorise=value
	WHERE IdCompte=idcpte;
END majdecouvertautorise;

--test question 3-
SELECT * FROM compte;
EXECUTE majdecouvertautorise (2,1000);
SELECT * FROM compte;

--*question4--
CREATE OR REPLACE PROCEDURE majmontantoperation (idopt INTEGER, value NUMBER)
IS
idcpte INTEGER;
BEGIN
	annuleroperation(idopt);
	SELECT Idcompte INTO idcpte from operation
	WHERE Idoperation=idopt;
	ajoutnoucvoperation(idcpte,value);
END majmontantoperation;

--test question4*
EXECUTE majmontantoperation (1,2000);
SELECT * FROM operation;

--question 5--
--*FAIRETRANSFERTCOMPTE(CptOrig INTEGER, CptDest INTEGER, Value NUMBER)
--*Cette procédure permet de réaliser un transfert d’argent entre comptes. 
--*Elle prend en paramètre l’identifiant du compte d’origine, l’identifiant
--* du compte destination et le montant du transfert. Ce montant est toujours positif. 
CREATE OR REPLACE PROCEDURE fairetransfertcompte (CptOrig INTEGER, CptDest INTEGER, Value NUMBER)
IS
BEGIN
		ajoutnoucvoperation(cptOrig,(-1*value));
		ajoutnoucvoperation(CptDest,value);

END fairetransfertcompte;		

--*test question5--
select *from compte;
EXECUTE fairetransfertcompte(1,2,100);
select *from operation;
		
  --*question 6--BANQUEOPERATION(Idopt INTEGER) RETURN VARCHAR
  CREATE OR REPLACE FUNCTION BANQUEOPERATION(Idopt INTEGER)
  RETURN VARCHAR
  IS
  libbanque VARCHAR(50);
  BEGIN
  SELECT B.LIBELLEBANQUE INTO  libbanque FROM BANQUE B 
  INNER JOIN COMPTE C ON B.IDBANQUE=C.idbanque
  INNER JOIN operation O ON C.IDCOMPTE=O.IDCOMPTE
  WHERE O.IDOPERATION=Idopt;
  RETURN libbanque; 
  END BANQUEOPERATION;
  
  --*test question6--
  select * from operation;
SELECT BANQUEOPERATION(1) FROM DUAL;
  
  --*question 7--SOLDECOMPTE(Cpt INTEGER) RETURN NUMBER
  --Cette fonction permet de retourner le solde du compte 
  --dont l’identifiant est passé en paramètre. Elle 
  --retourne un nombre.
  CREATE OR REPLACE FUNCTION SOLDECOMPTE(Cpt INTEGER)
  RETURN NUMBER
  IS 
  soldcpt NUMBER(10,2);
  BEGIN
  SELECT SOLDECOMPTE INTO soldcpt FROM COMPTE WHERE IDCOMPTE=Cpt;
  RETURN soldcpt; 
  END SOLDECOMPTE;
  
  
 --*test question7--
     select * from compte;
SELECT SOLDECOMPTE(1) FROM DUAL;

--*creation paquage--

CREATE OR REPLACE PACKAGE PROJETBANQUE
AS
 PROCEDURE ajoutnoucvoperation(idcompte INTEGER, value NUMBER);
 PROCEDURE annuleroperation(idopt INTEGER);
 PROCEDURE majdecouvertautorise (idcpte INTEGER, value NUMBER);
 PROCEDURE majmontantoperation (idopt INTEGER, value NUMBER);
 PROCEDURE fairetransfertcompte (CptOrig INTEGER, CptDest INTEGER, Value NUMBER);
 FUNCTION BANQUEOPERATION(Idopt INTEGER)RETURN VARCHAR;
 FUNCTION SOLDECOMPTE (Cpt INTEGER)RETURN NUMBER;
 END PROJETBANQUE;
 
 --*creation paquage BODY--
CREATE OR REPLACE PACKAGE BODY PROJETBANQUE
AS
	PROCEDURE ajoutnoucvoperation(idcompte INTEGER, value NUMBER)
	IS
	BEGIN
		INSERT INTO operation(IdOperation,DateOperation,MontantOperation,IdCompte)
		values(SeqIdOperation.NEXTVAL,SYSDATE,value,idcompte);
	END ajoutnoucvoperation;

	PROCEDURE annuleroperation(idopt INTEGER)
	IS
		mtoperation NUMBER(10,2);
		idcpte INTEGER;
	BEGIN
		SELECT montantoperation,IdCompte INTO mtoperation,idcpte from operation  
		WHERE IdOperation = idopt;
		INSERT INTO operation(IdOperation,DateOperation,MontantOperation,IdCompte)
		values(SeqIdOperation.NEXTVAL,SYSDATE,(mtoperation*-1),idcpte);
	END annuleroperation;

	PROCEDURE majdecouvertautorise (idcpte INTEGER, value NUMBER)
	IS
	BEGIN
		UPDATE COMPTE
		SET DecouvertAutorise=value
		WHERE IdCompte=idcpte;
	END majdecouvertautorise;

	PROCEDURE majmontantoperation (idopt INTEGER, value NUMBER)
	IS
		idcpte INTEGER;
	BEGIN
		annuleroperation(idopt);
		SELECT Idcompte INTO idcpte from operation
		WHERE Idoperation=idopt;
		ajoutnoucvoperation(idcpte,value);
	END majmontantoperation;
	
	PROCEDURE fairetransfertcompte (CptOrig INTEGER, CptDest INTEGER, Value NUMBER)
	IS
	BEGIN
		ajoutnoucvoperation(cptOrig,(-1*value));
		ajoutnoucvoperation(CptDest,value);

	END fairetransfertcompte;
	
	FUNCTION BANQUEOPERATION(Idopt INTEGER)
	RETURN VARCHAR
	IS
		libbanque VARCHAR(50);
	BEGIN
		SELECT B.LIBELLEBANQUE INTO  libbanque FROM BANQUE B 
		INNER JOIN COMPTE C ON B.IDBANQUE=C.idbanque
		INNER JOIN operation O ON C.IDCOMPTE=O.IDCOMPTE
		WHERE O.IDOPERATION=Idopt;
		RETURN libbanque; 
	END BANQUEOPERATION;
	
	FUNCTION SOLDECOMPTE(Cpt INTEGER)
	RETURN NUMBER
	IS 
		soldcpt NUMBER(10,2);
	BEGIN
		SELECT SOLDECOMPTE INTO soldcpt FROM COMPTE WHERE IDCOMPTE=Cpt;
		RETURN soldcpt; 
	END SOLDECOMPTE;
	
END PROJETBANQUE;

---TEST PACKAGE BODY---
SELECT PROJETBANQUE.SOLDECOMPTE(1) FROM DUAL;

---TRIGGERS---
--A chaque action sur la table opération (ajout d’une opération de débit ou crédit sur un
--compte, annulation d’une opération ou modification du montant d’une opération) 
--ce traitement calcule automatiquement le nouveau montant du solde du compte associé à
--l’opération.
CREATE TRIGGER MAJ_MONTANT
AFTER INSERT ON TABLE OPERATION
FOR EACH ROW
DECLARE

BEGIN
update COMPTE 
set soldecompte (:NEW.SoldeCompte=);
END;




