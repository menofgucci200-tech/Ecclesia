<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Enums\ParishStatus;
use App\Models\Parish;
use Illuminate\Database\Seeder;

class ParishSeeder extends Seeder
{
    /**
     * Seed a realistic set of parishes from the Archdiocese of Abidjan.
     */
    public function run(): void
    {
        foreach ($this->parishes() as $parish) {
            Parish::query()->updateOrCreate(
                ['code' => $parish['code']],
                [
                    ...$parish,
                    'status' => ParishStatus::Active->value,
                ],
            );
        }
    }

    /**
     * @return list<array<string, string>>
     */
    private function parishes(): array
    {
        $diocese = 'Archidiocèse d\'Abidjan';
        $region = 'District Autonome d\'Abidjan';
        $city = 'Abidjan';
        $country = 'Côte d\'Ivoire';

        $base = compact('diocese', 'region', 'city', 'country');

        return [
            [...$base, 'name' => 'Paroisse Saint-Jean-Baptiste', 'code' => 'STJEANBAPTISTE', 'commune' => 'Yopougon', 'address' => 'Yopougon Selmer, Abidjan', 'phone' => '+2252723000101', 'email' => 'contact@stjeanbaptiste.ci'],
            [...$base, 'name' => 'Paroisse Saint-Paul d\'Abobo', 'code' => 'STPAUL2026', 'commune' => 'Abobo', 'address' => 'Abobo Baoulé, Abidjan', 'phone' => '+2252724000102', 'email' => 'contact@stpaulabobo.ci'],
            [...$base, 'name' => 'Cathédrale Saint-Paul du Plateau', 'code' => 'CATHPLATEAU', 'commune' => 'Le Plateau', 'address' => 'Boulevard Angoulvant, Le Plateau, Abidjan', 'phone' => '+2252720000103', 'email' => 'cathedrale@archi-abidjan.ci'],
            [...$base, 'name' => 'Paroisse Saint-Jean de Cocody', 'code' => 'STJEANCOCODY', 'commune' => 'Cocody', 'address' => 'Cocody Danga, Abidjan', 'phone' => '+2252722000104', 'email' => 'contact@stjeancocody.ci'],
            [...$base, 'name' => 'Paroisse Christ-Roi de Riviera', 'code' => 'CHRISTROI', 'commune' => 'Cocody', 'address' => 'Riviera Golf, Cocody, Abidjan', 'phone' => '+2252722000105', 'email' => 'contact@christroi.ci'],
            [...$base, 'name' => 'Paroisse Notre-Dame de la Paix', 'code' => 'NDPAIX', 'commune' => 'Yopougon', 'address' => 'Yopougon Niangon, Abidjan', 'phone' => '+2252723000106', 'email' => 'contact@ndpaix.ci'],
            [...$base, 'name' => 'Paroisse Sacré-Cœur de Marcory', 'code' => 'SACRECOEUR', 'commune' => 'Marcory', 'address' => 'Marcory Résidentiel, Abidjan', 'phone' => '+2252721000107', 'email' => 'contact@sacrecoeur.ci'],
            [...$base, 'name' => 'Paroisse Saint-Michel d\'Adjamé', 'code' => 'STMICHEL', 'commune' => 'Adjamé', 'address' => 'Adjamé Liberté, Abidjan', 'phone' => '+2252720000108', 'email' => 'contact@stmichel.ci'],
            [...$base, 'name' => 'Paroisse Sainte-Thérèse de Treichville', 'code' => 'STETHERESE', 'commune' => 'Treichville', 'address' => 'Treichville Avenue 16, Abidjan', 'phone' => '+2252721000109', 'email' => 'contact@stetherese.ci'],
            [...$base, 'name' => 'Paroisse Saint-Joseph de Koumassi', 'code' => 'STJOSEPH', 'commune' => 'Koumassi', 'address' => 'Koumassi Grand-Marché, Abidjan', 'phone' => '+2252721000110', 'email' => 'contact@stjoseph.ci'],
            [...$base, 'name' => 'Paroisse Notre-Dame d\'Afrique', 'code' => 'NDAFRIQUE', 'commune' => 'Attécoubé', 'address' => 'Williamsville, Attécoubé, Abidjan', 'phone' => '+2252720000111', 'email' => 'contact@ndafrique.ci'],
            [...$base, 'name' => 'Paroisse Saint-Augustin de Bingerville', 'code' => 'STAUGUSTIN', 'commune' => 'Bingerville', 'address' => 'Bingerville Centre, Abidjan', 'phone' => '+2252722000112', 'email' => 'contact@staugustin.ci'],
        ];
    }
}
