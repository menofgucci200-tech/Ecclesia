<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('saints', function (Blueprint $table) {
            $table->id();
            $table->date('date')->unique();
            $table->string('feast')->nullable();          // AELF "fête" label
            $table->string('name')->nullable();           // resolved saint name
            $table->text('summary')->nullable();          // Wikipedia extract
            $table->text('image_url')->nullable();        // Wikipedia thumbnail URL
            $table->text('wikipedia_url')->nullable();
            $table->string('color')->nullable();          // liturgical colour
            $table->string('liturgical_day')->nullable(); // e.g. "mardi, 16ème Semaine…"
            $table->string('source')->default('aelf');    // aelf | manual
            $table->boolean('is_hidden')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('saints');
    }
};
