# -*- coding: utf-8 -*-
# Generated by Django 1.11.25 on 2023-07-13 18:20
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('lists', '0004_item_list'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='list',
            name='list',
        ),
    ]
