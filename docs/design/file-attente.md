# File d'attente (file virtuelle) — Snack (M7)

> Référence : `references/file-attente.png` · Conventions : [README.md](README.md)

## Rôle
File d'attente virtuelle : position et temps estimé avant que la commande soit prête.

## Composants
- Cercle central (`pink500` clair) avec le **nombre de commandes devant** (`3`, `display`/`h1` `pink600`).
- Titre « 3 commandes avant la vôtre » + « Temps d'attente estimé : 8 min ».
- Carte commande : `Commande #A1248` + **badge « En file »** + résumé articles.
- Note : « Vous serez notifié dès que votre commande est prête. »

## Tokens appliqués
- Cercle : fond `pink500` clair ; nombre : `pink600`.
- Badge « En file » : `info`/`blue600` + libellé.
- Titre : `h3` `neutral900` ; sous-textes : `bodyM`/`caption` `muted`.

## Règles métier
- Position et **temps estimé calculés serveur** — le Mobile affiche, ne calcule pas.
- Correspond à `QUEUED`/`PREPARING` ; passage à READY → notification + [commande prête](commande-prete.md).
- **Statut par badge + libellé** (« En file »), pas par couleur seule.

## ⚠️ Divergences
- Header « SUPE2I FOOD » → « SUP2I FOOD ».

## Plus tard
M7 : file virtuelle + mise à jour temps réel.
