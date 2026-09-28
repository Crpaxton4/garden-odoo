from odoo import fields, models


class ProductSeasonality(models.Model):
    _name = "product.seasonality"
    _description = "Product Seasonality and Growing Requirements"

    name = fields.Char(string="Name", required=True)

    # Planting windows represented as seasons for v1
    SEASONS = [
        ("spring", "Spring"),
        ("summer", "Summer"),
        ("autumn", "Autumn"),
        ("winter", "Winter"),
    ]

    planting_indoor = fields.Selection(selection=SEASONS, string="Planting (Indoor)")
    planting_outdoor = fields.Selection(selection=SEASONS, string="Planting (Outdoor)")

    # Growing time in days
    growing_time_days = fields.Integer(string="Growing Time (days)")
    growing_time_notes = fields.Text(string="Growing Time Notes")

    # Environmental requirements
    SUN = [
        ("full_sun", "Full sun"),
        ("partial_shade", "Partial shade"),
        ("shade", "Shade"),
    ]
    sun_requirements = fields.Selection(selection=SUN, string="Sun Requirements")

    WATER = [
        ("low", "Low"),
        ("medium", "Medium"),
        ("high", "High"),
    ]
    watering_requirements = fields.Selection(
        selection=WATER, string="Watering Requirements"
    )

    SOIL = [
        ("sandy", "Sandy"),
        ("loam", "Loam"),
        ("clay", "Clay"),
        ("peat", "Peat"),
    ]
    soil_requirements = fields.Selection(selection=SOIL, string="Soil Requirements")

    FORM = [
        ("seed", "Seed"),
        ("seedling", "Seedling"),
        ("plug", "Plug Tray"),
        ("bare_root", "Bare root"),
        ("transplant", "Transplant"),
    ]
    form_factor = fields.Selection(selection=FORM, string="Form Factor")

    # Relationship to product.template — Many2many so seasonality records can be shared
    product_tmpl_ids = fields.Many2many(
        comodel_name="product.template",
        relation="product_template_seasonality_rel",
        column1="seasonality_id",
        column2="product_tmpl_id",
        string="Product Templates",
    )

    active = fields.Boolean(default=True)


class ProductTemplate(models.Model):
    _inherit = "product.template"

    seasonality_ids = fields.Many2many(
        comodel_name="product.seasonality",
        relation="product_template_seasonality_rel",
        column1="product_tmpl_id",
        column2="seasonality_id",
        string="Seasonality",
    )
