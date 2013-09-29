Reijiro::Application.routes.draw do
  resources :words,  except: [:new]
  resources :clips,  only: [:index, :update, :destroy]

  get   '/clips/all' => 'clips#all', as: 'all_clips'

  get   '/levels/' => 'levels#index', as: 'levels'
  get   '/levels/:level' => 'levels#show', as: 'level'
  post  '/levels/known/:id' => 'levels#known', as: 'known'

  get   '/search' => 'words#search', as: 'search'
  post  '/alc(/:level)' => 'words#import_from_alc12000', as: 'alc'
  get   '/stats' => 'clips#stats', as: 'stats'
  get   '/next' => 'clips#nextup', as: 'next'
  post  '/import' => 'words#import', as: 'import'
  post  '/async_import/:word' => 'words#async_import'

  root 'clips#next'
end
