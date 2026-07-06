-- Script DDL : creation des tables, contraintes et triggers

DROP TABLE IF EXISTS LIGNE_ANALYSE;
DROP TABLE IF EXISTS ORDONNANCE_ANALYSE;
DROP TABLE IF EXISTS TYPE_ANALYSE;
DROP TABLE IF EXISTS PRESCRIPTION;
DROP TABLE IF EXISTS ORDONNANCE_MEDICAMENT;
DROP TABLE IF EXISTS ANTECEDENT;
DROP TABLE IF EXISTS MALADIE;
DROP TABLE IF EXISTS OPERATION;
DROP TABLE IF EXISTS SEJOUR;
DROP TABLE IF EXISTS ALLERGIE_FAMILLE;
DROP TABLE IF EXISTS ALLERGIE_MEDICAMENT;
DROP TABLE IF EXISTS VISITE;
DROP TABLE IF EXISTS MEDICAMENT;
DROP TABLE IF EXISTS FAMILLE_MEDICAMENT;
DROP TABLE IF EXISTS PATIENT;
DROP TABLE IF EXISTS SECRETAIRE;
DROP TABLE IF EXISTS MEDECIN;

-- Utilisateurs du cabinet
CREATE TABLE MEDECIN (
    NumMedecin      INT AUTO_INCREMENT PRIMARY KEY,
    NomMed          VARCHAR(40)  NOT NULL,
    PrenomMed       VARCHAR(40)  NOT NULL,
    Specialite      VARCHAR(60),
    Login           VARCHAR(30)  NOT NULL UNIQUE,
    MotDePasse      VARCHAR(255) NOT NULL
);

CREATE TABLE SECRETAIRE (
    NumSecretaire   INT AUTO_INCREMENT PRIMARY KEY,
    NomSec          VARCHAR(40) NOT NULL,
    PrenomSec       VARCHAR(40) NOT NULL,
    Login           VARCHAR(30) NOT NULL UNIQUE,
    MotDePasse      VARCHAR(255) NOT NULL
);

-- Patient et donnees medicales de base
CREATE TABLE PATIENT (
    NumPatient      INT AUTO_INCREMENT PRIMARY KEY,
    NomPat          VARCHAR(40) NOT NULL,
    PrenomPat       VARCHAR(40) NOT NULL,
    DateNaiss       DATE NOT NULL,
    Poids           DECIMAL(5,2),
    Taille          DECIMAL(5,2),
    Tel             VARCHAR(20),
    Adresse         VARCHAR(120),
    NumMedecin      INT NOT NULL,               -- medecin traitant
    CONSTRAINT fk_patient_medecin FOREIGN KEY (NumMedecin)
        REFERENCES MEDECIN(NumMedecin)
);

CREATE TABLE FAMILLE_MEDICAMENT (
    NumFamille      INT AUTO_INCREMENT PRIMARY KEY,
    NomFamille      VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE MEDICAMENT (
    NumMedicament   INT AUTO_INCREMENT PRIMARY KEY,
    NomMedic        VARCHAR(80) NOT NULL,
    Categorie       VARCHAR(60),
    Description     VARCHAR(255),
    NumFamille      INT NOT NULL,
    CONSTRAINT fk_medicament_famille FOREIGN KEY (NumFamille)
        REFERENCES FAMILLE_MEDICAMENT(NumFamille)
);

CREATE TABLE ALLERGIE_MEDICAMENT (
    NumPatient      INT NOT NULL,
    NumMedicament   INT NOT NULL,
    PRIMARY KEY (NumPatient, NumMedicament),
    CONSTRAINT fk_allmed_patient FOREIGN KEY (NumPatient)
        REFERENCES PATIENT(NumPatient),
    CONSTRAINT fk_allmed_medicament FOREIGN KEY (NumMedicament)
        REFERENCES MEDICAMENT(NumMedicament)
);

CREATE TABLE ALLERGIE_FAMILLE (
    NumPatient      INT NOT NULL,
    NumFamille      INT NOT NULL,
    PRIMARY KEY (NumPatient, NumFamille),
    CONSTRAINT fk_allfam_patient FOREIGN KEY (NumPatient)
        REFERENCES PATIENT(NumPatient),
    CONSTRAINT fk_allfam_famille FOREIGN KEY (NumFamille)
        REFERENCES FAMILLE_MEDICAMENT(NumFamille)
);

CREATE TABLE MALADIE (
    NumMaladie      INT AUTO_INCREMENT PRIMARY KEY,
    NomMaladie      VARCHAR(80) NOT NULL,
    Description     VARCHAR(255)
);

CREATE TABLE ANTECEDENT (
    NumPatient      INT NOT NULL,
    NumMaladie      INT NOT NULL,
    PRIMARY KEY (NumPatient, NumMaladie),
    CONSTRAINT fk_antecedent_patient FOREIGN KEY (NumPatient)
        REFERENCES PATIENT(NumPatient),
    CONSTRAINT fk_antecedent_maladie FOREIGN KEY (NumMaladie)
        REFERENCES MALADIE(NumMaladie)
);

CREATE TABLE SEJOUR (
    NumSejour       INT AUTO_INCREMENT PRIMARY KEY,
    Etablissement   VARCHAR(100) NOT NULL,
    DateDebut       DATE NOT NULL,
    DateFin         DATE,
    Motif           VARCHAR(255),
    NumPatient      INT NOT NULL,
    CONSTRAINT fk_sejour_patient FOREIGN KEY (NumPatient)
        REFERENCES PATIENT(NumPatient),
    CONSTRAINT chk_dates_sejour CHECK (DateFin IS NULL OR DateFin >= DateDebut)
);

CREATE TABLE OPERATION (
    NumOperation    INT AUTO_INCREMENT PRIMARY KEY,
    NomOperation    VARCHAR(100) NOT NULL,
    DateOp          DATE NOT NULL,
    Description     VARCHAR(255),
    NumSejour       INT NOT NULL,
    CONSTRAINT fk_operation_sejour FOREIGN KEY (NumSejour)
        REFERENCES SEJOUR(NumSejour)
);

-- Visites, ordonnances medicaments, prescriptions
CREATE TABLE VISITE (
    NumVisite       INT AUTO_INCREMENT PRIMARY KEY,
    DateVisite      DATETIME NOT NULL,
    Lieu            ENUM('CABINET','DOMICILE') NOT NULL DEFAULT 'CABINET',
    Motif           VARCHAR(255),
    NumPatient      INT NOT NULL,
    NumMedecin      INT NOT NULL,
    CONSTRAINT fk_visite_patient FOREIGN KEY (NumPatient)
        REFERENCES PATIENT(NumPatient),
    CONSTRAINT fk_visite_medecin FOREIGN KEY (NumMedecin)
        REFERENCES MEDECIN(NumMedecin)
);

CREATE TABLE ORDONNANCE_MEDICAMENT (
    NumOrdMed       INT AUTO_INCREMENT PRIMARY KEY,
    DateOrd         DATE NOT NULL,
    NumVisite       INT NOT NULL UNIQUE,        
    CONSTRAINT fk_ordmed_visite FOREIGN KEY (NumVisite)
        REFERENCES VISITE(NumVisite)
);

CREATE TABLE PRESCRIPTION (
    NumOrdMed           INT NOT NULL,
    NumMedicament       INT NOT NULL,
    NbPrises            INT NOT NULL,
    NbDosesParPrise     DECIMAL(4,1) NOT NULL,
    FreqJournaliere     INT NOT NULL,
    DureeTraitement     INT NOT NULL COMMENT 'en jours',
    PRIMARY KEY (NumOrdMed, NumMedicament),
    CONSTRAINT fk_prescription_ordmed FOREIGN KEY (NumOrdMed)
        REFERENCES ORDONNANCE_MEDICAMENT(NumOrdMed),
    CONSTRAINT fk_prescription_medicament FOREIGN KEY (NumMedicament)
        REFERENCES MEDICAMENT(NumMedicament),
    CONSTRAINT chk_posologie CHECK (NbPrises > 0 AND FreqJournaliere > 0 AND DureeTraitement > 0)
);

-- Ordonnances d'analyses
CREATE TABLE TYPE_ANALYSE (
    NumTypeAnalyse  INT AUTO_INCREMENT PRIMARY KEY,
    Libelle         VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE ORDONNANCE_ANALYSE (
    NumOrdAna       INT AUTO_INCREMENT PRIMARY KEY,
    DateOrd         DATE NOT NULL,
    NumVisite       INT NOT NULL UNIQUE,
    CONSTRAINT fk_ordana_visite FOREIGN KEY (NumVisite)
        REFERENCES VISITE(NumVisite)
);

CREATE TABLE LIGNE_ANALYSE (
    NumOrdAna       INT NOT NULL,
    NumTypeAnalyse  INT NOT NULL,
    Resultat        VARCHAR(255),
    DateResultat    DATE,
    PRIMARY KEY (NumOrdAna, NumTypeAnalyse),
    CONSTRAINT fk_ligneana_ordana FOREIGN KEY (NumOrdAna)
        REFERENCES ORDONNANCE_ANALYSE(NumOrdAna),
    CONSTRAINT fk_ligneana_type FOREIGN KEY (NumTypeAnalyse)
        REFERENCES TYPE_ANALYSE(NumTypeAnalyse)
);

-- TRIGGERS

-- 1) Empecher de prescrire un medicament auquel le patient est
--    allergique (directement ou via sa famille).
DELIMITER $$
CREATE TRIGGER trg_verif_allergie
BEFORE INSERT ON PRESCRIPTION
FOR EACH ROW
BEGIN
    DECLARE v_patient INT;
    DECLARE v_famille INT;
    DECLARE v_nb INT;

    SELECT V.NumPatient INTO v_patient
    FROM ORDONNANCE_MEDICAMENT OM
    JOIN VISITE V ON V.NumVisite = OM.NumVisite
    WHERE OM.NumOrdMed = NEW.NumOrdMed;

    SELECT COUNT(*) INTO v_nb
    FROM ALLERGIE_MEDICAMENT
    WHERE NumPatient = v_patient AND NumMedicament = NEW.NumMedicament;

    IF v_nb > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prescription refusee : patient allergique a ce medicament';
    END IF;

    SELECT NumFamille INTO v_famille
    FROM MEDICAMENT WHERE NumMedicament = NEW.NumMedicament;

    SELECT COUNT(*) INTO v_nb
    FROM ALLERGIE_FAMILLE
    WHERE NumPatient = v_patient AND NumFamille = v_famille;

    IF v_nb > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prescription refusee : patient allergique a la famille de ce medicament';
    END IF;
END$$
DELIMITER ;

-- 2) Une visite ne peut avoir qu'UNE seule ordonnance de
--    prescription de medicaments (deja garanti par UNIQUE sur
--    NumVisite, on le rend explicite et lisible via un trigger
--    de controle redondant, utile si la contrainte est levee).
DELIMITER $$
CREATE TRIGGER trg_unicite_ordmed_par_visite
BEFORE INSERT ON ORDONNANCE_MEDICAMENT
FOR EACH ROW
BEGIN
    DECLARE v_nb INT;
    SELECT COUNT(*) INTO v_nb FROM ORDONNANCE_MEDICAMENT WHERE NumVisite = NEW.NumVisite;
    IF v_nb > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cette visite dispose deja d une ordonnance de medicaments';
    END IF;
END$$
DELIMITER ;

-- 3) Au moins un medicament par ordonnance : verification a la
--    validation (AFTER INSERT sur PRESCRIPTION), on ne peut pas
--    le garantir avant, donc on controle via une procedure de
--    cloture d'ordonnance appelee cote application, ou par un
--    trigger sur DELETE qui empeche de vider une ordonnance.
DELIMITER $$
CREATE TRIGGER trg_min_un_medicament
BEFORE DELETE ON PRESCRIPTION
FOR EACH ROW
BEGIN
    DECLARE v_nb INT;
    SELECT COUNT(*) INTO v_nb FROM PRESCRIPTION WHERE NumOrdMed = OLD.NumOrdMed;
    IF v_nb <= 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Une ordonnance doit contenir au moins un medicament';
    END IF;
END$$
DELIMITER ;

-- 4) Coherence des dates de sejour deja geree par CHECK
--    (chk_dates_sejour) ci-dessus.