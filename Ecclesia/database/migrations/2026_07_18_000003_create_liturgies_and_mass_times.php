<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Daily liturgy, auto-filled from AELF and editable by the super admin.
        Schema::create('liturgies', function (Blueprint $table) {
            $table->id();
            $table->date('date')->index();
            $table->string('zone', 20)->default('afrique');
            $table->string('liturgical_day');            // ex. "16ème dimanche du Temps Ordinaire"
            $table->string('season')->nullable();        // ex. "ordinaire"
            $table->string('color', 20)->nullable();     // ex. "vert"
            $table->string('week')->nullable();          // ex. "semaine IV du Psautier"
            $table->json('readings')->nullable();        // [{type, ref, title, intro, content, refrain, verse}]
            $table->string('source', 10)->default('aelf'); // aelf | manual
            $table->boolean('is_hidden')->default(false);
            $table->timestamp('synced_at')->nullable();
            $table->timestamps();

            $table->unique(['date', 'zone']);
        });

        // Mass schedule, per parish, managed by the parish admin.
        Schema::create('mass_times', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parish_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('day_of_week');  // 0 = dimanche … 6 = samedi
            $table->time('time');
            $table->string('label')->nullable();         // ex. "Messe dominicale", "Messe des jeunes"
            $table->string('note')->nullable();          // ex. "Chorale Sainte-Cécile"
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['parish_id', 'day_of_week']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('mass_times');
        Schema::dropIfExists('liturgies');
    }
};
