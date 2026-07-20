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
        // Parish movements (chorale, légion de Marie, servants de messe…).
        Schema::create('movements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parish_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('category')->nullable();       // ex. "Chorale", "Prière", "Jeunesse"
            $table->text('description')->nullable();
            $table->string('logo')->nullable();
            $table->string('meeting_info')->nullable();    // ex. "Samedi 16h, salle 2"
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // A movement leader authenticates with a login just like a parish admin.
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('movement_id')->nullable()->after('parish_id')->index();
        });

        // Membership: the faithful join movements.
        Schema::create('movement_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('movement_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->timestamp('joined_at')->nullable();
            $table->timestamps();

            $table->unique(['movement_id', 'user_id']);
        });

        // Movement posts (news / announcements published by the leaders).
        Schema::create('movement_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('movement_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('body');
            $table->string('image')->nullable();
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
        });

        // Movement documents (PDF, images…).
        Schema::create('movement_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('movement_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('file_path');
            $table->string('mime')->nullable();
            $table->unsignedBigInteger('size')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('movement_id');
        });
        Schema::dropIfExists('movement_documents');
        Schema::dropIfExists('movement_posts');
        Schema::dropIfExists('movement_user');
        Schema::dropIfExists('movements');
    }
};
