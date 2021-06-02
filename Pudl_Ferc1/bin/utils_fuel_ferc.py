"""Collection of functions for analyzing fuel_ferc dataset."""

from typing import Dict
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
import statsmodels.api as sm



def load_data(infile: str) -> pd.DataFrame:
    """Load csv input file and return as a dataframe."""
    return pd.read_csv(infile)


def explore_data(data: pd.DataFrame) -> pd.DataFrame:
    """Look at summary statistics and basic dist plots."""

    # What columns do we have and are they complete?
    print(data.info())
    # 12 columns and no missing values


    # What report years do we have?
    print("\nYears:", data['report_year'].unique())
    # > Only 1994


    # What fuel type codes are there?
    print("\nFuel type codes:", data['fuel_type_code_pudl'].unique())
    # 6 types: ['coal' 'gas' 'nuclear' 'oil' 'waste' 'unknown']


    # What is the fuel type code distribution?
    print("\nFuel type code dist:")
    print(data['fuel_type_code_pudl'].value_counts())


    # Fuel type code distribution as a bar plot
    # data['fuel_type_code_pudl'].value_counts().plot(kind='bar')
    # plt.show()


    # Are there different fuel units used for each fuel type code?
    print("\nFuel type code vs fuel units dist:")
    print(data[['fuel_type_code_pudl', 'fuel_unit']].value_counts())
    # Most fuel type codes use a singular unit type, but each fuel type
    # works with different fuel units, like coal-ton, gas-mcf


    # What is the fuel qty burned by fuel type?
    print("\nFuel qty burned by fuel type code:")
    fuel_type_qty_burned = (data[['fuel_type_code_pudl', 'fuel_qty_burned']]
        .copy()
        .groupby('fuel_type_code_pudl')
        .sum('fuel_qty_burned')
        .reset_index()
        .assign(fuel_qty_burned=lambda x: x['fuel_qty_burned'].map(round))
        .sort_values('fuel_qty_burned', ascending=False)
    )
    print(fuel_type_qty_burned)

    return data


def make_fuel_cost_bar_plot(data: pd.DataFrame) -> pd.DataFrame:
    """Make seaborn bar plot of fuel cost per mmbtu (heat content)."""
    src_data = (data[['fuel_type_code_pudl', 'fuel_cost_per_mmbtu']]
        .copy()
        .groupby('fuel_type_code_pudl')
        .mean('fuel_cost_per_mmbtu')
        .reset_index()
        .sort_values('fuel_cost_per_mmbtu')
    )

    print("\nFuel cost per mmbtu by fuel type code:")
    print(src_data)


    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(9, 9))
    g = sns.barplot(x='fuel_cost_per_mmbtu', y='fuel_type_code_pudl',
                    color='blue',
                    data=src_data)
    plt.xlabel('')
    plt.ylabel('')
    plt.title('Mean Fuel Cost Per MMBTU (Heat Content) by Fuel Type Code')
    # plt.show()
    plt.savefig("../results/mean_fuel_cost_mmbut_byType.png")

    # Comments on resulting bar plot:
    #   Nuclear seems to have the lowest fuel cost per mmbtu (a measure of heat
    #   content), while coal is second. Waste is at the very bottom with a much
    #   higher fuel cost.

    return data


def make_fuel_cost_scat_plot(data: pd.DataFrame) -> pd.DataFrame:
    """Make seaborn scatter plot of fuel cost per unit burned vs fuel cost per mmbtu."""
    src_data = data[['fuel_type_code_pudl',
                     'fuel_cost_per_unit_burned',
                     'fuel_cost_per_mmbtu']].copy()

    rp = sns.relplot(data=src_data,
                     x='fuel_cost_per_unit_burned', y='fuel_cost_per_mmbtu',
                     col='fuel_type_code_pudl', col_wrap=3,
                     kind='scatter', alpha=0.5)

    rp.fig.subplots_adjust(top=0.9)
    rp.fig.suptitle('Fuel Cost per MMBTU (y) vs Fuel Cost per Unit Burned (x)')
    rp.set_titles("{col_name}")

    rp.set(xscale="log")
    rp.set(yscale="log")

    # plt.show()
    rp.savefig("../results/fuel_cost_mmbtu_vs_unit_burned_scat.png")

    # Comments on resulting scatter plot:
    #   A few of the fuel types (coal, gas, oil) seem to have linear relationships
    #   in log-log scale between fuel cost per mmbtu and the fuel cost per unit burned

    return data


def fit_sk_lm(data: pd.DataFrame) -> Dict[str, pd.DataFrame]:
    """Fits and interprets sklearn linear regression model and examines its fit."""
    coal = data.query('fuel_type_code_pudl == "coal"')

    # fuel_x = coal[['fuel_qty_burned', 'fuel_cost_per_unit_burned']]
    fuel_x = coal[['fuel_cost_per_unit_burned']]
    fuel_y = coal['fuel_cost_per_mmbtu']

    X_train, X_test, y_train, y_test = train_test_split(fuel_x, fuel_y,
                                                        test_size=0.25,
                                                        random_state=23)
    model = LinearRegression().fit(X_train, y_train)

    y_pred = model.predict(X_test)

    print(f"\nModel Coefs: {model.coef_}")
    print(f"Test R^2: {round(r2_score(y_test, y_pred), 4)}")
    print(f"Test MSE: {round(mean_squared_error(y_test, y_pred), 4)}")

    return {'X_train': X_train, 'X_test': X_test,
            'y_train': y_train, 'y_test': y_test}


def fit_stats_lm(model_data: Dict[str, pd.DataFrame]) -> None:
    """Fits and interprets statsmodels linear regression model and examines its fit."""

    model = sm.OLS(model_data['y_train'], model_data['X_train'])

    results = model.fit()

    print("\nStatsmodels LM Summary:")
    print(results.summary())

    y_pred = results.predict(model_data['X_test'])

    print(f"\nTest R^2: {round(r2_score(model_data['y_test'], y_pred), 4)}")
    print(f"Test MSE: {round(mean_squared_error(model_data['y_test'], y_pred), 4)}")

    # Make scatter of training set with regression line from model
    fig, ax = plt.subplots()
    ax.scatter(model_data['X_test'], model_data['y_test'], color='purple')
    ax.plot(model_data['X_test'], y_pred, color='green')
    ax.set_title('[Fuel Type = Coal] Test Set Linear Regression')
    ax.set_xlabel('Fuel Cost per Unit Burned')
    ax.set_ylabel('Fuel Cost per MMBTU')
    # plt.show()
    plt.savefig("../results/test_lm_cost_mmbtu_unit_burned.png")
