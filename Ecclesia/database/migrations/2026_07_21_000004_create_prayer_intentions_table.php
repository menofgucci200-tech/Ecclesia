<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('prayer_intentions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parish_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('author_name')->nullable();
            $table->boolean('is_anonymous')->default(false);
            $table->text('intention');
            $table->unsignedInteger('prayers_count')->default(0);
            $table->boolean('is_approved')->default(true);
            $table->timestamps();
            $table->index(['parish_id', 'is_approved']);
        });

        // Who has prayed for an intention (prevents double-counting).
        Schema::create('prayer_intention_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('prayer_intention_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['prayer_intention_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('prayer_intention_user');
        Schema::dropIfExists('prayer_intentions');
    }
};
