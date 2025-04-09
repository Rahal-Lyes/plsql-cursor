# TP PLSQL – Niveau M1 ISIL – Schéma HR

## Objectif
Manipulation du langage PL/SQL avec le schéma `HR` d'Oracle. L'objectif est de pratiquer l'écriture de fonctions, procédures, curseurs, gestion des exceptions, et mise à jour de tables.

---

## a) Affichage des informations des employés
Écriture d'un bloc PL/SQL qui affiche les informations des employés sous un format bien aligné avec :

- Prénom et nom
- Ancien salaire
- Nouveau salaire (calculé à partir de la commission)

---

## b) Fonction `New_SAL(old_sal, pct)`
Fonction qui retourne :

```sql
new_salary := old_sal * (1 + pct);
