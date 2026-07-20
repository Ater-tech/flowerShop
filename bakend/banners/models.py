from django.db import models


class Banner(models.Model):
    title = models.CharField(max_length=255, blank=True)
    image = models.ImageField(upload_to='banners/')
    link_url = models.URLField(blank=True, null=True)
    order = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    start_date = models.DateTimeField(blank=True, null=True)
    end_date = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order', '-created_at']

    def __str__(self):
        return self.title or f"Banner {self.pk}"