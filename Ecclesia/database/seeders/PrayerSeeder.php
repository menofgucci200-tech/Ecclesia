<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Prayer;
use Illuminate\Database\Seeder;

/**
 * Seeds a starter library of standard, public-domain French Catholic prayers,
 * rosaries, a novena and a litany. Idempotent (keyed on category + title), so
 * it can be re-run safely; every entry stays editable/deletable in the
 * dashboard.
 */
class PrayerSeeder extends Seeder
{
    public function run(): void
    {
        foreach ($this->items() as $item) {
            Prayer::updateOrCreate(
                ['category' => $item['category'], 'title' => $item['title']],
                [
                    'subtitle' => $item['subtitle'] ?? null,
                    'body' => trim($item['body']),
                    'reference' => $item['reference'] ?? null,
                    'position' => $item['position'],
                    'is_published' => true,
                ],
            );
        }
    }

    /** @return array<int, array<string, mixed>> */
    private function items(): array
    {
        return [
            // ---------------------------- Prières ----------------------------
            ['category' => 'priere', 'position' => 1, 'title' => 'Signe de croix', 'subtitle' => 'Prière fondamentale',
                'body' => 'Au nom du Père, et du Fils, et du Saint-Esprit. Amen.'],

            ['category' => 'priere', 'position' => 2, 'title' => 'Notre Père', 'subtitle' => 'La prière du Seigneur', 'reference' => 'Mt 6, 9-13',
                'body' => <<<'TXT'
Notre Père, qui es aux cieux,
que ton nom soit sanctifié,
que ton règne vienne,
que ta volonté soit faite sur la terre comme au ciel.

Donne-nous aujourd'hui notre pain de ce jour.
Pardonne-nous nos offenses,
comme nous pardonnons aussi à ceux qui nous ont offensés.
Et ne nous laisse pas entrer en tentation,
mais délivre-nous du Mal.

Amen.
TXT],

            ['category' => 'priere', 'position' => 3, 'title' => 'Je vous salue Marie', 'subtitle' => 'Prière mariale',
                'body' => <<<'TXT'
Je vous salue, Marie, pleine de grâce ;
le Seigneur est avec vous.
Vous êtes bénie entre toutes les femmes,
et Jésus, le fruit de vos entrailles, est béni.

Sainte Marie, Mère de Dieu,
priez pour nous, pauvres pécheurs,
maintenant et à l'heure de notre mort.

Amen.
TXT],

            ['category' => 'priere', 'position' => 4, 'title' => 'Gloire au Père', 'subtitle' => 'Doxologie',
                'body' => <<<'TXT'
Gloire au Père, et au Fils, et au Saint-Esprit,
comme il était au commencement, maintenant et toujours,
et dans les siècles des siècles.

Amen.
TXT],

            ['category' => 'priere', 'position' => 5, 'title' => 'Je crois en Dieu', 'subtitle' => 'Symbole des Apôtres',
                'body' => <<<'TXT'
Je crois en Dieu, le Père tout-puissant,
créateur du ciel et de la terre ;
et en Jésus Christ, son Fils unique, notre Seigneur,
qui a été conçu du Saint-Esprit,
est né de la Vierge Marie,
a souffert sous Ponce Pilate,
a été crucifié, est mort et a été enseveli,
est descendu aux enfers,
le troisième jour est ressuscité des morts,
est monté aux cieux,
est assis à la droite de Dieu le Père tout-puissant,
d'où il viendra juger les vivants et les morts.

Je crois en l'Esprit Saint,
à la sainte Église catholique,
à la communion des saints,
à la rémission des péchés,
à la résurrection de la chair,
à la vie éternelle.

Amen.
TXT],

            ['category' => 'priere', 'position' => 6, 'title' => 'Je confesse à Dieu', 'subtitle' => 'Confiteor',
                'body' => <<<'TXT'
Je confesse à Dieu tout-puissant,
je reconnais devant mes frères,
que j'ai péché en pensée, en parole, par action et par omission ;
oui, j'ai vraiment péché.

C'est pourquoi je supplie la bienheureuse Vierge Marie,
les anges et tous les saints,
et vous aussi, mes frères,
de prier pour moi le Seigneur notre Dieu.

Amen.
TXT],

            ['category' => 'priere', 'position' => 7, 'title' => 'Acte de contrition',
                'body' => <<<'TXT'
Mon Dieu, j'ai un très grand regret de vous avoir offensé,
parce que vous êtes infiniment bon, infiniment aimable,
et que le péché vous déplaît.

Je prends la ferme résolution, avec le secours de votre sainte grâce,
de ne plus vous offenser et de faire pénitence.

Amen.
TXT],

            ['category' => 'priere', 'position' => 8, 'title' => 'Prière à l\'Ange gardien',
                'body' => <<<'TXT'
Ange de Dieu, qui êtes mon gardien,
et à qui la bonté divine m'a confié,
éclairez-moi, gardez-moi,
dirigez-moi et gouvernez-moi.

Amen.
TXT],

            ['category' => 'priere', 'position' => 9, 'title' => 'Viens, Esprit Saint',
                'body' => <<<'TXT'
Viens, Esprit Saint, remplis le cœur de tes fidèles
et allume en eux le feu de ton amour.
Envoie ton Esprit et tout sera créé,
et tu renouvelleras la face de la terre.

Prions.
Dieu qui as instruit le cœur de tes fidèles par la lumière du Saint-Esprit,
donne-nous, par ce même Esprit, de goûter ce qui est bien
et de jouir sans cesse de ses consolations.
Par le Christ, notre Seigneur. Amen.
TXT],

            ['category' => 'priere', 'position' => 10, 'title' => 'Angélus',
                'body' => <<<'TXT'
℣. L'ange du Seigneur porta l'annonce à Marie,
℟. Et elle conçut du Saint-Esprit.
Je vous salue, Marie…

℣. Voici la servante du Seigneur,
℟. Qu'il me soit fait selon votre parole.
Je vous salue, Marie…

℣. Et le Verbe s'est fait chair,
℟. Et il a habité parmi nous.
Je vous salue, Marie…

℣. Priez pour nous, sainte Mère de Dieu,
℟. Afin que nous soyons rendus dignes des promesses du Christ.

Prions.
Que ta grâce, Seigneur, se répande en nos cœurs.
Par le message de l'ange, tu nous as fait connaître
l'Incarnation de ton Fils bien-aimé ;
conduis-nous, par sa passion et par sa croix,
jusqu'à la gloire de la résurrection.
Par le Christ, notre Seigneur. Amen.
TXT],

            ['category' => 'priere', 'position' => 11, 'title' => 'Je vous salue, Reine', 'subtitle' => 'Salve Regina',
                'body' => <<<'TXT'
Je vous salue, Reine, Mère de miséricorde,
notre vie, notre douceur, notre espérance, salut !
Enfants d'Ève, exilés, nous crions vers vous.
Vers vous, nous soupirons, gémissant et pleurant
dans cette vallée de larmes.

Ô vous, notre avocate,
tournez vers nous vos regards miséricordieux.
Et, après cet exil, montrez-nous Jésus,
le fruit béni de vos entrailles,
ô clémente, ô miséricordieuse, ô douce Vierge Marie !
TXT],

            // --------------------------- Chapelets ---------------------------
            ['category' => 'chapelet', 'position' => 1, 'title' => 'Le Saint Rosaire', 'subtitle' => 'Comment prier le chapelet',
                'body' => <<<'TXT'
Le chapelet se compose de cinq dizaines. Chaque dizaine médite un « mystère » de la vie du Christ et de la Vierge Marie.

POUR COMMENCER
• Faire le signe de croix.
• Réciter le « Je crois en Dieu ».
• Un « Notre Père », trois « Je vous salue Marie », un « Gloire au Père ».

POUR CHAQUE DIZAINE
• Annoncer le mystère.
• Un « Notre Père ».
• Dix « Je vous salue Marie » en méditant le mystère.
• Un « Gloire au Père ».
• (On peut ajouter : « Ô mon Jésus, pardonnez-nous nos péchés… »)

LES MYSTÈRES

Mystères joyeux (lundi et samedi)
1. L'Annonciation
2. La Visitation
3. La Nativité
4. La Présentation de Jésus au Temple
5. Le Recouvrement de Jésus au Temple

Mystères lumineux (jeudi)
1. Le Baptême de Jésus au Jourdain
2. Les Noces de Cana
3. L'annonce du Royaume de Dieu
4. La Transfiguration
5. L'institution de l'Eucharistie

Mystères douloureux (mardi et vendredi)
1. L'Agonie de Jésus au jardin des Oliviers
2. La Flagellation
3. Le Couronnement d'épines
4. Le Portement de la Croix
5. La Crucifixion et la mort de Jésus

Mystères glorieux (mercredi et dimanche)
1. La Résurrection
2. L'Ascension
3. La Pentecôte
4. L'Assomption de la Vierge Marie
5. Le Couronnement de la Vierge Marie

POUR CONCLURE
• « Je vous salue, Reine » (Salve Regina).
TXT],

            ['category' => 'chapelet', 'position' => 2, 'title' => 'Chapelet de la Divine Miséricorde', 'subtitle' => 'Sur un chapelet ordinaire',
                'body' => <<<'TXT'
Ce chapelet se récite sur un chapelet ordinaire.

POUR COMMENCER
• Un « Notre Père », un « Je vous salue Marie », le « Je crois en Dieu ».

SUR LES GROS GRAINS (avant chaque dizaine)
« Père Éternel, je vous offre le Corps et le Sang,
l'Âme et la Divinité de votre Fils bien-aimé,
notre Seigneur Jésus Christ,
en réparation de nos péchés et de ceux du monde entier. »

SUR LES PETITS GRAINS (dix fois par dizaine)
« Par sa douloureuse Passion,
soyez miséricordieux pour nous et pour le monde entier. »

POUR CONCLURE (trois fois)
« Dieu Saint, Dieu Fort, Dieu Éternel,
prenez pitié de nous et du monde entier. »
TXT],

            // --------------------------- Neuvaine ----------------------------
            ['category' => 'neuvaine', 'position' => 1, 'title' => 'Neuvaine à l\'Esprit Saint', 'subtitle' => 'À prier neuf jours de suite',
                'body' => <<<'TXT'
À réciter chaque jour, neuf jours de suite.

Esprit Saint, Esprit de Dieu,
descends en moi et fais de mon cœur ta demeure.
Donne-moi tes sept dons :
sagesse, intelligence, conseil, force,
science, piété et crainte de Dieu.

Éclaire mon intelligence, fortifie ma volonté,
purifie mon cœur et sanctifie mon âme.
Rends-moi docile à tes inspirations
et fidèle à la volonté du Père.

(Formuler ici son intention.)

Notre Père… Je vous salue Marie… Gloire au Père…

Viens, Esprit Saint, remplis le cœur de tes fidèles
et allume en eux le feu de ton amour. Amen.
TXT],

            // ---------------------------- Litanie -----------------------------
            ['category' => 'litanie', 'position' => 1, 'title' => 'Litanies de la Sainte Vierge', 'subtitle' => 'Litanies de Lorette',
                'body' => <<<'TXT'
Seigneur, ayez pitié de nous.
Ô Christ, ayez pitié de nous.
Seigneur, ayez pitié de nous.

Christ, écoutez-nous.
Christ, exaucez-nous.

Sainte Marie, priez pour nous.
Sainte Mère de Dieu, priez pour nous.
Sainte Vierge des vierges, priez pour nous.
Mère du Christ, priez pour nous.
Mère de l'Église, priez pour nous.
Mère de la divine grâce, priez pour nous.
Mère très pure, priez pour nous.
Mère très chaste, priez pour nous.
Mère toujours vierge, priez pour nous.
Mère aimable, priez pour nous.
Mère admirable, priez pour nous.
Mère du bon conseil, priez pour nous.
Mère du Créateur, priez pour nous.
Mère du Sauveur, priez pour nous.
Vierge très prudente, priez pour nous.
Vierge digne de vénération, priez pour nous.
Vierge digne de louange, priez pour nous.
Vierge puissante, priez pour nous.
Vierge clémente, priez pour nous.
Vierge fidèle, priez pour nous.
Miroir de justice, priez pour nous.
Trône de la Sagesse, priez pour nous.
Cause de notre joie, priez pour nous.
Reine des Anges, priez pour nous.
Reine des Patriarches, priez pour nous.
Reine des Prophètes, priez pour nous.
Reine des Apôtres, priez pour nous.
Reine des Martyrs, priez pour nous.
Reine de tous les Saints, priez pour nous.
Reine du très saint Rosaire, priez pour nous.
Reine de la paix, priez pour nous.

Agneau de Dieu qui enlevez les péchés du monde,
pardonnez-nous, Seigneur.
Agneau de Dieu qui enlevez les péchés du monde,
exaucez-nous, Seigneur.
Agneau de Dieu qui enlevez les péchés du monde,
ayez pitié de nous.
TXT],

            // -------------------- Prières (suite) ---------------------------
            ['category' => 'priere', 'position' => 12, 'title' => 'Prière du matin',
                'body' => <<<'TXT'
Mon Dieu, je vous adore et je vous aime de tout mon cœur.
Je vous remercie de m'avoir créé, racheté,
et gardé pendant cette nuit.

Je vous offre toutes mes actions de cette journée :
faites qu'elles soient selon votre sainte volonté
et pour votre plus grande gloire.
Préservez-moi du péché et de tout mal.

Que votre grâce soit toujours avec moi
et avec tous ceux qui me sont chers. Amen.
TXT],

            ['category' => 'priere', 'position' => 13, 'title' => 'Prière du soir',
                'body' => <<<'TXT'
Mon Dieu, au terme de cette journée, je vous remercie de tous vos bienfaits.
Je vous demande pardon pour les fautes que j'ai commises.

Veillez sur mon repos et sur celui de tous les hommes.
Bénissez ma famille, mes amis et tous ceux qui souffrent.
Donnez le repos éternel aux défunts.

Je me confie à vous pour cette nuit. Amen.
TXT],

            ['category' => 'priere', 'position' => 14, 'title' => 'Bénédicité', 'subtitle' => 'Avant le repas',
                'body' => <<<'TXT'
Bénissez-nous, Seigneur, bénissez ce repas,
ceux qui l'ont préparé,
et procurez du pain à ceux qui n'en ont pas.
Par le Christ, notre Seigneur. Amen.
TXT],

            ['category' => 'priere', 'position' => 15, 'title' => 'Action de grâces', 'subtitle' => 'Après le repas',
                'body' => <<<'TXT'
Nous vous rendons grâces pour tous vos bienfaits,
ô Dieu tout-puissant, qui vivez et régnez
pour les siècles des siècles. Amen.
TXT],

            ['category' => 'priere', 'position' => 16, 'title' => 'Acte de foi',
                'body' => <<<'TXT'
Mon Dieu, je crois fermement toutes les vérités que vous avez révélées
et que vous nous enseignez par votre Église,
parce que vous ne pouvez ni vous tromper ni nous tromper. Amen.
TXT],

            ['category' => 'priere', 'position' => 17, 'title' => 'Acte d\'espérance',
                'body' => <<<'TXT'
Mon Dieu, j'espère avec une ferme confiance que vous me donnerez,
par les mérites de Jésus Christ,
votre grâce en ce monde et le bonheur éternel dans l'autre,
parce que vous l'avez promis et que vous êtes fidèle dans vos promesses. Amen.
TXT],

            ['category' => 'priere', 'position' => 18, 'title' => 'Acte de charité',
                'body' => <<<'TXT'
Mon Dieu, je vous aime de tout mon cœur et par-dessus toute chose,
parce que vous êtes infiniment bon et infiniment aimable ;
et j'aime mon prochain comme moi-même pour l'amour de vous. Amen.
TXT],

            ['category' => 'priere', 'position' => 19, 'title' => 'Souvenez-vous', 'subtitle' => 'Memorare',
                'body' => <<<'TXT'
Souvenez-vous, ô très miséricordieuse Vierge Marie,
qu'on n'a jamais entendu dire qu'aucun de ceux qui ont eu recours à votre protection,
imploré votre assistance ou réclamé vos suffrages,
ait été abandonné.

Animé d'une pareille confiance, ô Vierge des vierges, ô ma Mère,
je viens vers vous, et, gémissant sous le poids de mes péchés,
je me prosterne à vos pieds.

Ô Mère du Verbe incarné, ne méprisez pas mes prières,
mais écoutez-les favorablement et daignez les exaucer. Amen.
TXT],

            ['category' => 'priere', 'position' => 20, 'title' => 'Âme du Christ', 'subtitle' => 'Anima Christi',
                'body' => <<<'TXT'
Âme du Christ, sanctifie-moi.
Corps du Christ, sauve-moi.
Sang du Christ, enivre-moi.
Eau du côté du Christ, lave-moi.
Passion du Christ, fortifie-moi.
Ô bon Jésus, exauce-moi.
Dans tes blessures, cache-moi.
Ne permets pas que je sois séparé de toi.
De l'ennemi défends-moi.
À ma mort appelle-moi.
Ordonne-moi de venir à toi,
pour qu'avec tes saints je te loue,
dans les siècles des siècles. Amen.
TXT],

            ['category' => 'priere', 'position' => 21, 'title' => 'Prière à saint Michel Archange',
                'body' => <<<'TXT'
Saint Michel Archange, défendez-nous dans le combat ;
soyez notre secours contre la malice et les embûches du démon.

Que Dieu lui commande, nous vous en supplions ;
et vous, Prince de la milice céleste,
par la vertu divine, repoussez en enfer Satan
et les autres esprits mauvais
qui rôdent dans le monde pour la perte des âmes. Amen.
TXT],

            ['category' => 'priere', 'position' => 22, 'title' => 'Prière pour les défunts',
                'body' => <<<'TXT'
Seigneur, donne-leur le repos éternel,
et que la lumière sans déclin brille sur eux.

Qu'ils reposent en paix. Amen.
TXT],

            // -------------------- Chapelets (suite) -------------------------
            ['category' => 'chapelet', 'position' => 3, 'title' => 'Chemin de Croix', 'subtitle' => 'Les quatorze stations',
                'body' => <<<'TXT'
Le Chemin de Croix médite la Passion du Seigneur en quatorze stations.

À chaque station :
« Nous vous adorons, ô Christ, et nous vous bénissons,
parce que vous avez racheté le monde par votre sainte Croix. »

1. Jésus est condamné à mort.
2. Jésus est chargé de sa croix.
3. Jésus tombe pour la première fois.
4. Jésus rencontre sa Mère.
5. Simon de Cyrène aide Jésus à porter sa croix.
6. Véronique essuie le visage de Jésus.
7. Jésus tombe pour la deuxième fois.
8. Jésus console les filles de Jérusalem.
9. Jésus tombe pour la troisième fois.
10. Jésus est dépouillé de ses vêtements.
11. Jésus est cloué sur la croix.
12. Jésus meurt sur la croix.
13. Jésus est descendu de la croix et remis à sa Mère.
14. Jésus est mis au tombeau.

Seigneur, donne-moi de porter ma croix chaque jour à ta suite. Amen.
TXT],

            // -------------------- Neuvaines (suite) -------------------------
            ['category' => 'neuvaine', 'position' => 2, 'title' => 'Neuvaine à la Vierge Marie', 'subtitle' => 'À prier neuf jours de suite',
                'body' => <<<'TXT'
Ô Marie, conçue sans péché,
priez pour nous qui avons recours à vous.

Sainte Vierge Marie, Mère de Dieu et notre Mère,
je me tourne vers vous avec confiance.
Vous n'abandonnez jamais ceux qui vous invoquent.

Présentez à votre Fils Jésus l'intention que je vous confie
(formuler ici son intention),
et obtenez-moi la grâce de faire en tout la volonté de Dieu.

Je vous salue Marie… (trois fois)

Ô Marie, Mère de miséricorde, priez pour moi. Amen.
TXT],

            ['category' => 'neuvaine', 'position' => 3, 'title' => 'Neuvaine à saint Joseph', 'subtitle' => 'À prier neuf jours de suite',
                'body' => <<<'TXT'
Glorieux saint Joseph, époux de Marie,
protecteur de la Sainte Famille et patron de l'Église,
je viens à vous avec confiance.

Vous qui avez veillé sur Jésus et Marie,
veillez sur moi et sur ceux que j'aime.
Obtenez-moi de Dieu la grâce que je vous demande
(formuler ici son intention),
et apprenez-moi à travailler, à prier et à aimer comme vous.
Soutenez-moi à l'heure de ma mort.

Notre Père… Je vous salue Marie… Gloire au Père…

Saint Joseph, priez pour nous. Amen.
TXT],

            // -------------------- Litanies (suite) --------------------------
            ['category' => 'litanie', 'position' => 2, 'title' => 'Litanies du Sacré-Cœur de Jésus',
                'body' => <<<'TXT'
Seigneur, ayez pitié de nous.
Jésus-Christ, ayez pitié de nous.
Seigneur, ayez pitié de nous.
Jésus-Christ, écoutez-nous.
Jésus-Christ, exaucez-nous.

Père céleste, qui êtes Dieu, ayez pitié de nous.
Dieu le Fils, Rédempteur du monde, ayez pitié de nous.
Dieu le Saint-Esprit, ayez pitié de nous.
Trinité sainte, qui êtes un seul Dieu, ayez pitié de nous.

Cœur de Jésus, uni substantiellement au Verbe de Dieu, ayez pitié de nous.
Cœur de Jésus, sanctuaire de la Divinité, ayez pitié de nous.
Cœur de Jésus, temple de la sainte Trinité, ayez pitié de nous.
Cœur de Jésus, abîme de sagesse, ayez pitié de nous.
Cœur de Jésus, océan de bonté, ayez pitié de nous.
Cœur de Jésus, trône de miséricorde, ayez pitié de nous.
Cœur de Jésus, trésor inépuisable, ayez pitié de nous.
Cœur de Jésus, notre paix et notre réconciliation, ayez pitié de nous.
Cœur de Jésus, modèle de toutes les vertus, ayez pitié de nous.
Cœur de Jésus, infiniment aimable, ayez pitié de nous.
Cœur de Jésus, source d'eau vive qui jaillit jusqu'à la vie éternelle, ayez pitié de nous.
Cœur de Jésus, propitiation pour nos péchés, ayez pitié de nous.
Cœur de Jésus, percé d'une lance, ayez pitié de nous.
Cœur de Jésus, brisé de douleur à cause de nos péchés, ayez pitié de nous.
Cœur de Jésus, refuge des pécheurs, ayez pitié de nous.
Cœur de Jésus, force des faibles, ayez pitié de nous.
Cœur de Jésus, consolation des affligés, ayez pitié de nous.
Cœur de Jésus, persévérance des justes, ayez pitié de nous.
Cœur de Jésus, salut de ceux qui espèrent en vous, ayez pitié de nous.
Cœur de Jésus, espérance des mourants, ayez pitié de nous.
Cœur de Jésus, délices de tous les Saints, ayez pitié de nous.

Agneau de Dieu, qui effacez les péchés du monde, pardonnez-nous, Jésus.
Agneau de Dieu, qui effacez les péchés du monde, exaucez-nous, Jésus.
Agneau de Dieu, qui effacez les péchés du monde, ayez pitié de nous, Jésus.
TXT],
        ];
    }
}
