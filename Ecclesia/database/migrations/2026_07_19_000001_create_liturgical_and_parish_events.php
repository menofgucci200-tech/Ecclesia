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
        // Major liturgical feasts of the year, auto-filled from the LitCal API.
        Schema::create('liturgical_events', function (Blueprint $table) {
            $table->id();
            $table->date('date')->index();
            $table->unsignedSmallInteger('year')->index();
            $table->string('name');
            $table->unsignedTinyInteger('grade')->default(0);   // 4 feast … 7 highest
            $table->string('grade_label')->nullable();          // ex. "SOLENNITÉ"
            $table->string('color', 30)->nullable();            // ex. "blanc"
            $table->string('season')->nullable();
            $table->string('source', 10)->default('litcal');    // litcal | manual
            $table->boolean('is_hidden')->default(false);
            $table->timestamp('synced_at')->nullable();
            $table->timestamps();

            $table->unique(['date', 'name']);
        });

        // Parish events, managed by the parish admin.
        Schema::create('parish_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parish_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->dateTime('starts_at')->index();
            $table->dateTime('ends_at')->nullable();
            $table->string('location')->nullable();
            $table->string('image')->nullable();
            $table->boolean('is_published')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('parish_events');
        Schema::dropIfExists('liturgical_events');
    }
};
