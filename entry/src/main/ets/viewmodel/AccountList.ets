

import AccountItem from '../viewmodel/AccountItem';

export const PayList: Array<AccountItem> = [
  {
    icon: $rawfile('foods.png'),
    iconSelected: $rawfile('foods_selected.png'),
    accountType: 0,
    typeText: 'foods'
  },
  {
    icon: $rawfile('snacks.png'),
    iconSelected: $rawfile('snacks_selected.png'),
    accountType: 0,
    typeText: 'snacks'
  },
  {
    icon: $rawfile('fuel.png'),
    iconSelected: $rawfile('fuel_selected.png'),
    accountType: 0,
    typeText: 'fuel'
  },
  {
    icon: $rawfile('travel.png'),
    iconSelected: $rawfile('travel_selected.png'),
    accountType: 0,
    typeText: 'travel'
  },
  {
    icon: $rawfile('games.png'),
    iconSelected: $rawfile('games_selected.png'),
    accountType: 0,
    typeText: 'games'
  },
  {
    icon: $rawfile('pets.png'),
    iconSelected: $rawfile('pets_selected.png'),
    accountType: 0,
    typeText: 'pets'
  }
]

export const EarnList: Array<AccountItem> = [
  {
    icon: $rawfile('income.png'),
    iconSelected: $rawfile('income_selected.png'),
    accountType: 1,
    typeText: 'income'
  },
  {
    icon: $rawfile('invest.png'),
    iconSelected: $rawfile('invest_selected.png'),
    accountType: 1,
    typeText: 'invest'
  }
]

export const ImageList: Record<string,Resource> = {
  'foods': $rawfile('foods.png'),
  'snacks': $rawfile('snacks.png'),
  'fuel': $rawfile('fuel.png'),
  'travel': $rawfile('travel.png'),
  'games': $rawfile('games.png'),
  'pets': $rawfile('pets.png'),
  'income': $rawfile('income.png'),
  'invest': $rawfile('invest.png')
}

export const TextList: Record<string,Resource> = {
  'foods': $r('app.string.foods'),
  'snacks': $r('app.string.snacks'),
  'fuel': $r('app.string.fuel'),
  'travel': $r('app.string.travel'),
  'games': $r('app.string.games'),
  'pets': $r('app.string.pets'),
  'income': $r('app.string.income'),
  'invest': $r('app.string.invest')
}