<?php

use App\Enums\AnnouncementCategory;
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
        Schema::create('announcements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parish_id')->constrained()->cascadeOnDelete();
            $table->string('category', 30)->default(AnnouncementCategory::Announcement->value)->index();
            $table->string('title');
            $table->text('body');
            $table->string('image_url')->nullable();
            $table->string('video_url')->nullable();
            $table->string('author_name');
            $table->string('author_role')->nullable();
            $table->boolean('is_pinned')->default(false);
            $table->boolean('is_important')->default(false);
            $table->unsignedInteger('likes_count')->default(0);
            $table->unsignedInteger('comments_count')->default(0);
            $table->timestamp('published_at')->nullable()->index();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('announcements');
    }
};
